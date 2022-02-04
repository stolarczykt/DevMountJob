require_relative 'test_helper'

module Advertisements
  class PublishAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'publish advertisement' do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      content = "Content: #{SecureRandom.hex}"
      time_when_published = Time.now
      travel_in_time_to(time_when_published)
      due_date = time_when_published + FakeDueDatePolicy::FAKE_VALID_FOR_SECONDS

      assert_events(
          stream,
          AdvertisementPublished.new(
              data: {
                  advertisement_id: advertisement_id,
                  author_id: author_id,
                  content: content,
                  due_date: due_date
              }
          )
      ) do
        act(PublishAdvertisement.new(advertisement_id, author_id, content))
      end
    end

    test "can't publish advertisement when empty or nil content" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number

      assert_raises(Advertisement::MissingContent) do
        act(PublishAdvertisement.new(advertisement_id, author_id, ""))
      end

      assert_raises(Advertisement::MissingContent) do
        act(PublishAdvertisement.new(advertisement_id, author_id, "     "))
      end

      assert_raises(Advertisement::MissingContent) do
        act(PublishAdvertisement.new(advertisement_id, author_id, nil))
      end
    end

    test "can't be publish twice in a row" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      content = "Content: #{SecureRandom.hex}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id, content)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(PublishAdvertisement.new(advertisement_id, author_id, content))
      end
      assert_equal "Publish allowed only from [draft], but was [published]", error.message
    end

    test "can't publish on hold advertisement" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      content = "Content: #{SecureRandom.hex}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id, content),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(PublishAdvertisement.new(advertisement_id, author_id, content))
      end
      assert_equal "Publish allowed only from [draft], but was [on_hold]", error.message
    end

    test "can't publish suspended advertisement" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      content = "Content: #{SecureRandom.hex}"
      suspend_reason = "Reason: #{SecureRandom.hex}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id, content),
        SuspendAdvertisement.new(advertisement_id, suspend_reason)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(PublishAdvertisement.new(advertisement_id, author_id, content))
      end
      assert_equal "Publish allowed only from [draft], but was [suspended]", error.message
    end

    test "can't publish expired advertisement" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      content = "Content: #{SecureRandom.hex}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id, content),
        ExpireAdvertisement.new(advertisement_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(PublishAdvertisement.new(advertisement_id, author_id, content))
      end
      assert_equal "Publish allowed only from [draft], but was [expired]", error.message
    end
  end
end
