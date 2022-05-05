require_relative 'test_helper'
require 'securerandom'

module Offering
  class MakeAnOfferTest < ActiveSupport::TestCase
    include OfferingTestPlumbing

    test 'make an offer' do
      offer_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      recipient_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
      salary_expectation = Expectation.new("Salary", true)
      stream = "Offer$#{offer_id}"

      assert_events(
        stream,
        OfferMade.new(
          data: {
            offer_id: offer_id,
            advertisement_id: advertisement_id,
            recruiter_id: recruiter_id,
            recipient_id: recipient_id,
            contact_details: contact_details
          }
        )
      ) do
        act(MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, recipient_id, contact_details, [], [salary_expectation]))
      end
    end

    test "can't make an another offer to the same advertisement" do
      first_offer_id = SecureRandom.uuid
      second_offer_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      recipient_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
      arrange(
        MakeAnOffer.new(first_offer_id, advertisement_id, recruiter_id, recipient_id, contact_details, [], [])
      )

      assert_raises(Offer::OfferAlreadyMade) do
        act(MakeAnOffer.new(second_offer_id, advertisement_id, recruiter_id, recipient_id, contact_details, [recruiter_id], []))
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
        act(MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, recipient_id, contact_details, [], expectations))
      end
    end

    test "different recruiters can make offers to the same advertisement" do
      advertisement_id = SecureRandom.uuid
      recipient_id = SecureRandom.uuid
      contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"

      first_offer_id = SecureRandom.uuid
      second_offer_id = SecureRandom.uuid
      third_offer_id = SecureRandom.uuid
      first_recruiter_id = SecureRandom.uuid
      second_recruiter_id = SecureRandom.uuid
      third_recruiter_id = SecureRandom.uuid

      act(MakeAnOffer.new(first_offer_id, advertisement_id, first_recruiter_id, recipient_id, contact_details, [], []))
      act(MakeAnOffer.new(second_offer_id, advertisement_id, second_recruiter_id, recipient_id, contact_details, [first_recruiter_id], []))
      act(MakeAnOffer.new(third_offer_id, advertisement_id, third_recruiter_id, recipient_id, contact_details, [first_recruiter_id, second_recruiter_id], []))
    end

    test "can't make already made offer" do
      offer_data = arrange_making_an_offer

      error = assert_raises(UnexpectedStateTransition) do
        act(
          MakeAnOffer.new(
            offer_data.offer_id,
            offer_data.advertisement_id,
            offer_data.recruiter_id,
            offer_data.recipient_id,
            offer_data.contact_details,
            offer_data.other_recruiters,
            offer_data.expectations
          )
        )
      end
      assert_equal :made, error.current_state
      assert_equal :initialized, error.desired_states
    end

    test "can't make an offer when rejected" do
      offer_data = arrange_making_an_offer
      arrange(
        RejectOffer.new(offer_data.offer_id, offer_data.recipient_id)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(MakeAnOffer.new(offer_data.offer_id, offer_data.advertisement_id, offer_data.recruiter_id, offer_data.recipient_id, offer_data.contact_details, offer_data.other_recruiters, offer_data.expectations))
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
      other_recruiters = []
      expectations = []

      assert_raises(Offer::MissingAdvertisement) do
        act(MakeAnOffer.new(offer_id, nil, recruiter_id, recipient_id, contact_details, other_recruiters, expectations))
      end

      assert_raises(Offer::MissingRecruiter) do
        act(MakeAnOffer.new(offer_id, advertisement_id, nil, recipient_id, contact_details, other_recruiters, expectations))
      end

      assert_raises(Offer::MissingRecipient) do
        act(MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, nil, contact_details, other_recruiters, expectations))
      end

      assert_raises(Offer::MissingContactDetails) do
        act(MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, recipient_id, nil, other_recruiters, expectations))
      end

      assert_raises(Offer::MissingContactDetails) do
        act(MakeAnOffer.new(offer_id, advertisement_id, recruiter_id, recipient_id, "", other_recruiters, expectations))
      end
    end
  end
end
