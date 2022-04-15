require_relative 'test_helper'
require 'securerandom'

module Offering
  class MakeAnOfferTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'make an offer' do
      offer_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
      stream = "Offer$#{offer_id}"

      assert_events(
        stream,
        OfferMade.new(
          data: {
            offer_id: offer_id,
            advertisement_id: advertisement_id,
            recruiter_id: recruiter_id,
            contact_details: contact_details
          }
        )
      ) do
        act(MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, contact_details))
      end
    end

    # todo: come up with a way of checking whether recruiter already made an offer to the advertisement
    # test "can't make an another offer to the same advertisement" do
    #   first_offer_id = SecureRandom.uuid
    #   second_offer_id = SecureRandom.uuid
    #   advertisement_id = SecureRandom.uuid
    #   recruiter_id = SecureRandom.uuid
    #   contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
    #   arrange(
    #     MakeAnOffer.new(first_offer_id, advertisement_id, recruiter_id, contact_details)
    #   )
    #
    #   assert_raises(OfferAlreadyMade) do
    #     act(MakeAnOffer.new(second_offer_id, advertisement_id, recruiter_id, contact_details))
    #   end
    # end

    test "can't make already made offer" do
      offer_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
      arrange(
        MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, contact_details)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, contact_details))
      end
      assert_equal :made, error.current_state
      assert_equal :initialized, error.desired_states
    end

    test "can't make an offer when rejected" do
      offer_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      requester_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
      arrange(
        MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, contact_details),
        RejectOffer.new(offer_id, requester_id)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, contact_details))
      end
      assert_equal :rejected, error.current_state
      assert_equal :initialized, error.desired_states
    end

    test 'fail when missing arguments' do
      offer_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"

      assert_raises(Offer::MissingAdvertisement) do
        act(MakeAnOffer.new(offer_id, nil, recruiter_id, contact_details))
      end

      assert_raises(Offer::MissingRecruiter) do
        act(MakeAnOffer.new(offer_id, advertisement_id, nil, contact_details))
      end

      assert_raises(Offer::MissingContactDetails) do
        act(MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, nil))
      end

      assert_raises(Offer::MissingContactDetails) do
        act(MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, ""))
      end
    end
  end
end
