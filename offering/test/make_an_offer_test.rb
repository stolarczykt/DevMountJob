require_relative 'test_helper'
require 'securerandom'

module Offering
  class MakeAnOfferTest < ActiveSupport::TestCase
    include OfferingTestPlumbing

    test 'make an offer' do
      offer_data = arrange_request_an_offer

      assert_events(
        offer_data.stream,
        OfferMade.new(
          data: {
            offer_id: offer_data.offer_id
          }
        )
      ) do
        act(MakeAnOffer.new(offer_data.offer_id, []))
      end
    end

    test "can't make a new offer if already made to the same advertisement" do
      offer_data = arrange_request_an_offer

      assert_raises(Offer::OfferAlreadyMade) do
        act(MakeAnOffer.new(offer_data.offer_id, [offer_data.recruiter_id]))
      end
    end

    test "can't make already made offer" do
      offer_data = arrange_making_an_offer

      error = assert_raises(UnexpectedStateTransition) do
        act(
          MakeAnOffer.new(
            offer_data.offer_id,
            offer_data.other_recruiters
          )
        )
      end
      assert_equal :made, error.current_state
      assert_equal :requested, error.desired_states
    end

    test "can't make an offer when rejected" do
      offer_data = arrange_making_an_offer
      arrange(
        RejectOffer.new(offer_data.offer_id, offer_data.recipient_id)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(MakeAnOffer.new(offer_data.offer_id, offer_data.other_recruiters))
      end
      assert_equal :rejected, error.current_state
      assert_equal :requested, error.desired_states
    end
  end
end
