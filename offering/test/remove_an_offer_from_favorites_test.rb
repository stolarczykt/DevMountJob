require_relative 'test_helper'
require 'securerandom'

module Offering
  class RemoveAnOfferFromFavoritesTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'remove an offer from favorites' do
      offer_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      recipient_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
      stream = "Offer$#{offer_id}"
      arrange(
        MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, recipient_id, contact_details),
      )

      assert_events(
        stream,
        OfferRemovedFromFavorites.new(
          data: {
            offer_id: offer_id
          }
        )
      ) do
        act(RemoveAnOfferFromFavorites.new(offer_id, recipient_id))
      end
    end

    test "can't remove from favorites if not made" do
      offer_id = SecureRandom.uuid
      requester_id = SecureRandom.uuid

      error = assert_raises(UnexpectedStateTransition) do
        act(RemoveAnOfferFromFavorites.new(offer_id, requester_id))
      end
      assert_equal :initialized, error.current_state
      assert_equal :made, error.desired_states
    end

    test "can't remove someone else's offer from favorites" do
      offer_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      recipient_id = SecureRandom.uuid
      requester_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
      arrange(
        MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, recipient_id, contact_details),
      )

      assert_raises(Offer::NotAnOfferRecipient) do
        act(RemoveAnOfferFromFavorites.new(offer_id, requester_id))
      end
    end
  end
end
