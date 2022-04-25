require_relative 'test_helper'
require 'securerandom'

module Offering
  class RejectOfferTest < ActiveSupport::TestCase
    include OfferingTestPlumbing

    test 'reject an offer' do
      offer_data = arrange_making_an_offer

      assert_events(
        offer_data.stream,
        OfferRejected.new(
          data: {
            offer_id: offer_data.offer_id
          }
        )
      ) do
        act(RejectOffer.new(offer_data.offer_id, offer_data.recipient_id))
      end
    end

    test "can't reject if not made" do
      error = assert_raises(UnexpectedStateTransition) do
        act(RejectOffer.new(SecureRandom.uuid, SecureRandom.uuid))
      end
      assert_equal :initialized, error.current_state
      assert_equal :made, error.desired_states
    end

    test "can't reject someone else's offer" do
      offer_data = arrange_making_an_offer

      assert_raises(Offer::NotAnOfferRecipient) do
        act(RejectOffer.new(offer_data.offer_id, SecureRandom.uuid))
      end
    end
  end
end
