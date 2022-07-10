require_relative 'test_helper'
require 'securerandom'

module Offering
  class OfferingProcessTest < ActiveSupport::TestCase

    test 'no recruiters when making offer for the first time' do
      command_bus = FakeCommandBus.new
      process = OfferingProcess.new
      offer_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid

      process.perform(
        YAML.dump(Offering::OfferRequested.new(
          data: {
            offer_id: offer_id,
            advertisement_id: SecureRandom.uuid,
            recruiter_id: recruiter_id,
            recipient_id: SecureRandom.uuid,
            contact_details: "Contact details: #{SecureRandom.alphanumeric(100)}"
          }
        )), command_bus
      )

      received = command_bus.received
      assert_equal(received.offer_id, offer_id)
      assert_equal(received.other_recruiters, [])
    end

    test 'command contains all previous recruiters that put an offer' do
      command_bus = FakeCommandBus.new
      process = OfferingProcess.new
      offer_id = SecureRandom.uuid
      first_recruiter_id = SecureRandom.uuid
      second_recruiter_id = SecureRandom.uuid
      third_recruiter_id = SecureRandom.uuid
      offer_requested_event = Offering::OfferRequested.new(
        data: {
          offer_id: offer_id,
          advertisement_id: SecureRandom.uuid,
          recipient_id: SecureRandom.uuid,
          contact_details: "Contact details: #{SecureRandom.alphanumeric(100)}"
        }
      )

      offer_requested_event.data[:recruiter_id] = first_recruiter_id
      process.perform(YAML.dump(offer_requested_event), command_bus)
      offer_requested_event.data[:recruiter_id] = second_recruiter_id
      process.perform(YAML.dump(offer_requested_event), command_bus)
      offer_requested_event.data[:recruiter_id] = third_recruiter_id
      process.perform(YAML.dump(offer_requested_event), command_bus)

      received = command_bus.received
      assert_equal(received.offer_id, offer_id)
      assert_equal(received.other_recruiters, [first_recruiter_id, second_recruiter_id])
    end
  end
end
