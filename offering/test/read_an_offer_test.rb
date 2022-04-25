require_relative 'test_helper'
require 'securerandom'

module Offering
  class ReadAnOfferTest < ActiveSupport::TestCase
    include OfferingTestPlumbing

    test 'read an offer' do
      offer_data = arrange_making_an_offer

      assert_events(
        offer_data.stream,
        OfferRead.new(
          data: {
            offer_id: offer_data.offer_id
          }
        )
      ) do
        act(ReadAnOffer.new(offer_data.offer_id, offer_data.recipient_id))
      end
    end

    test "can't read if not made" do
      error = assert_raises(UnexpectedStateTransition) do
        act(ReadAnOffer.new(SecureRandom.uuid, SecureRandom.uuid))
      end
      assert_equal :initialized, error.current_state
      assert_equal :made, error.desired_states
    end

    test "can't read someone else's offer" do
      offer_data = arrange_making_an_offer

      assert_raises(Offer::NotAnOfferRecipient) do
        act(ReadAnOffer.new(offer_data.offer_id, SecureRandom.uuid))
      end
    end
  end
end
