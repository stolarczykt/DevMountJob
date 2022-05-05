require_relative 'test_helper'
require 'securerandom'

module Offering
  class AddAnOfferToFavoritesTest < ActiveSupport::TestCase
    include OfferingTestPlumbing

    test 'add an offer to favorites' do
      offer_data = arrange_making_an_offer

      assert_events(
        offer_data.stream,
        OfferAddedToFavorites.new(
          data: {
            offer_id: offer_data.offer_id
          }
        )
      ) do
        act(AddAnOfferToFavorites.new(offer_data.offer_id, offer_data.recipient_id))
      end
    end

    test "can't add to favorites if not made" do
      error = assert_raises(OperationNotAllowed) do
        act(AddAnOfferToFavorites.new(SecureRandom.uuid, SecureRandom.uuid))
      end
      assert_equal :initialized, error.current_state
    end

    test "can't add someone else's offer to favorites" do
      offer_data = arrange_making_an_offer

      assert_raises(Offer::NotAnOfferRecipient) do
        act(AddAnOfferToFavorites.new(offer_data.offer_id, SecureRandom.uuid))
      end
    end
  end
end
