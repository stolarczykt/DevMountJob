require_relative 'test_helper'

module Advertisements
  class ChangeAdvertisementsContentTest < ActiveSupport::TestCase

    test 'change advertisement content' do
      advertisement_id = 68456
      author_id = 7382
      stream = "Advertisement$#{advertisement_id}"
      new_content = "Astonishing new content!!!"
      command_bus = Rails.configuration.command_bus
      command_bus.(PublishAdvertisement.new(advertisement_id, author_id))

      assert_events(
          stream,
          ContentHasChanged.new(data: {content: new_content})
      ) do
        command_bus.(ChangeContent.new(advertisement_id, new_content, author_id))
      end
    end

    test 'do not allow changing content if not an author' do
      advertisement_id = 68456
      author_id = 7382
      not_an_author_id = 5456456
      new_content = "Astonishing new content!!!"
      command_bus = Rails.configuration.command_bus
      command_bus.(PublishAdvertisement.new(advertisement_id, author_id))

      assert_raises(Advertisement::NotAnAuthorOfAdvertisement) do
        command_bus.(ChangeContent.new(advertisement_id, new_content, not_an_author_id))
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
