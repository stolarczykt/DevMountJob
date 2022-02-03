require_relative 'test_helper'
require 'securerandom'

module Advertisements
  class ChangeAdvertisementsContentTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'change advertisement content' do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      original_content = "Content: #{SecureRandom.hex}"
      new_content = "Random content: #{SecureRandom.hex}"
      arrange(PublishAdvertisement.new(advertisement_id, author_id, original_content))

      assert_events(
          "Advertisement$#{advertisement_id}",
          ContentHasChanged.new(
            data: {
              advertisement_id: advertisement_id,
              content: new_content
            }
          )
      ) do
        act(ChangeContent.new(advertisement_id, new_content, author_id))
      end
    end

    test "can't change the content to empty or nil" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      original_content = "Content: #{SecureRandom.hex}"
      arrange(PublishAdvertisement.new(advertisement_id, author_id, original_content))

      assert_raises(Advertisement::MissingContent) do
        act(ChangeContent.new(advertisement_id, "", author_id))
      end

      assert_raises(Advertisement::MissingContent) do
        act(ChangeContent.new(advertisement_id, nil, author_id))
      end
    end

    test 'do not allow changing content if not an author' do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      not_an_author_id = SecureRandom.random_number
      original_content = "Content: #{SecureRandom.hex}"
      new_content = "Random content: #{SecureRandom.hex}"
      arrange(PublishAdvertisement.new(advertisement_id, author_id, original_content))

      assert_raises(Advertisement::NotAnAuthorOfAdvertisement) do
        act(ChangeContent.new(advertisement_id, new_content, not_an_author_id))
      end
    end
  end
end
