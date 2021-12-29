require_relative 'test_helper'
require 'securerandom'

module Advertisements
  class ChangeAdvertisementsContentTest < ActiveSupport::TestCase
    include TestPlumbing

    command_bus = Rails.configuration.command_bus

    test 'change advertisement content' do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      new_content = "Random content: #{SecureRandom.hex}"
      command_bus.(PublishAdvertisement.new(advertisement_id, author_id))

      assert_events(
          "Advertisement$#{advertisement_id}",
          ContentHasChanged.new(data: {content: new_content})
      ) do
        command_bus.(ChangeContent.new(advertisement_id, new_content, author_id))
      end
    end

    test 'do not allow changing content if not an author' do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      not_an_author_id = SecureRandom.random_number
      new_content = "Random content: #{SecureRandom.hex}"
      command_bus.(PublishAdvertisement.new(advertisement_id, author_id))

      assert_raises(Advertisement::NotAnAuthorOfAdvertisement) do
        command_bus.(ChangeContent.new(advertisement_id, new_content, not_an_author_id))
      end
    end
  end
end
