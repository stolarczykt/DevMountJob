require_relative 'test_helper'
require 'securerandom'

module Offering
  class RequestAnOfferTest < ActiveSupport::TestCase
    include OfferingTestPlumbing

    test 'request an offer' do
      offer_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      recipient_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
      salary_expectation = Expectation.new("Salary", true)
      stream = "Offer$#{offer_id}"

      assert_events(
        stream,
        OfferRequested.new(
          data: {
            offer_id: offer_id,
            advertisement_id: advertisement_id,
            recruiter_id: recruiter_id,
            recipient_id: recipient_id,
            contact_details: contact_details
          }
        )
      ) do
        act(RequestAnOffer.new(offer_id, advertisement_id, recruiter_id, recipient_id, contact_details, [salary_expectation]))
      end
    end

    test "fail when not all expectations fulfilled" do
      offer_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      recipient_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
      salary_expectation = Expectation.new("Salary", true)
      location_expectation = Expectation.new("Location", false)
      expectations = [salary_expectation, location_expectation]

      assert_raises(Offer::ExpectationsNotFulfilled) do
        act(RequestAnOffer.new(offer_id, advertisement_id, recruiter_id, recipient_id, contact_details, expectations))
      end
    end

    test "can't request already requested offer" do
      offer_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      recipient_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
      expectations = []

      arrange(
        Offering::RequestAnOffer.new(
          offer_id,
          advertisement_id,
          recruiter_id,
          recipient_id,
          contact_details,
          expectations
        )
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(
          RequestAnOffer.new(
            offer_id,
            advertisement_id,
            recruiter_id,
            recipient_id,
            contact_details,
            expectations
          )
        )
      end
      assert_equal :requested, error.current_state
      assert_equal :initialized, error.desired_states
    end

    test "can't request an offer when rejected" do
      offer_data = arrange_making_an_offer
      arrange(
        RejectOffer.new(offer_data.offer_id, offer_data.recipient_id)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(RequestAnOffer.new(offer_data.offer_id, offer_data.advertisement_id, offer_data.recruiter_id, offer_data.recipient_id, offer_data.contact_details, offer_data.expectations))
      end
      assert_equal :rejected, error.current_state
      assert_equal :initialized, error.desired_states
    end

    test 'fail when missing arguments' do
      offer_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      recipient_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
      expectations = []

      assert_raises(Offer::MissingAdvertisement) do
        act(RequestAnOffer.new(offer_id, nil, recruiter_id, recipient_id, contact_details, expectations))
      end

      assert_raises(Offer::MissingRecruiter) do
        act(RequestAnOffer.new(offer_id, advertisement_id, nil, recipient_id, contact_details, expectations))
      end

      assert_raises(Offer::MissingRecipient) do
        act(RequestAnOffer.new(offer_id, advertisement_id, recruiter_id, nil, contact_details, expectations))
      end

      assert_raises(Offer::MissingContactDetails) do
        act(RequestAnOffer.new(offer_id, advertisement_id, recruiter_id, recipient_id, nil, expectations))
      end

      assert_raises(Offer::MissingContactDetails) do
        act(RequestAnOffer.new(offer_id, advertisement_id, recruiter_id, recipient_id, "", expectations))
      end
    end
  end
end
