require_relative 'test_helper'

module Advertisements
  class ChangeAdvertisementsContentTest < ActiveSupport::TestCase
    test 'change advertisement content' do
      advertisement_id = 51654
      repository = AdvertisementRepository.new
      stream = "Advertisement$#{advertisement_id}"
      new_content = "Astonishing new content!!!"

      assert_events(
          stream,
          ContentHasChanged.new(data: {content: new_content})
      ) do
        repository.with_advertisement(advertisement_id) do |advertisement|
          advertisement.change_content(new_content)
        end
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
