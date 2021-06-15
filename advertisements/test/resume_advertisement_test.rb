require_relative 'test_helper'

module Advertisements
  class ChangeAdvertisementsContentTest < ActiveSupport::TestCase

    test 'resume advertisement' do
      advertisement_id = 68456
      stream = "Advertisement$#{advertisement_id}"
      command_bus = Rails.configuration.command_bus

      assert_events(
          stream,
          AdvertisementResumed.new
      ) do
        command_bus.(ResumeAdvertisement.new(advertisement_id))
      end
    end

    def assert_events(stream_name, *expected_events)
      scope = Rails.configuration.event_store.read.stream(stream_name)
      before = scope.last
      yield
      actual_events = before.nil? ? scope.to_a : scope.from(before.event_id).to_a
      to_compare = ->(ev) { { type: ev.event_type, data: ev.data } }
      assert_equal expected_events.map(&to_compare),
                   actual_events.map(&to_compare)
    end
  end
end
