require_relative 'test_helper'
require 'securerandom'

module Offering
  class RemoveAnOfferFromFavoritesTest < ActiveSupport::TestCase
    include OfferingTestPlumbing

    test 'remove an offer from favorites' do
      offer_data = arrange_making_an_offer

      assert_events(
        offer_data.stream,
        OfferRemovedFromFavorites.new(
          data: {
            offer_id: offer_data.offer_id
          }
        )
      ) do
        act(RemoveAnOfferFromFavorites.new(offer_data.offer_id, offer_data.recipient_id))
      end
    end

    test "can't remove from favorites if not made" do
      error = assert_raises(UnexpectedStateTransition) do
        act(RemoveAnOfferFromFavorites.new(SecureRandom.uuid, SecureRandom.uuid))
      end
      assert_equal :initialized, error.current_state
      assert_equal :made, error.desired_states
    end

    test "can't remove someone else's offer from favorites" do
      offer_data = arrange_making_an_offer

      assert_raises(Offer::NotAnOfferRecipient) do
        act(RemoveAnOfferFromFavorites.new(offer_data.offer_id, SecureRandom.uuid))
      end
    end
  end
end
