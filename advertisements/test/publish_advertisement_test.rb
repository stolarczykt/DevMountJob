require_relative 'test_helper'

module Advertisements
  class PublishAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'publish advertisement' do
      advertisement_id = SecureRandom.uuid
      author_id = SecureRandom.uuid
      stream = "Advertisement$#{advertisement_id}"
      content = "Content: #{SecureRandom.hex}"
      time_when_published = Time.now
      travel_in_time_to(time_when_published)
      due_date = time_when_published + FakeDueDatePolicy::PUBLISH_FOR_SECONDS

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

    test 'fail to publish when missing author' do
      advertisement_id = SecureRandom.uuid
      content = "Content: #{SecureRandom.hex}"

      assert_raises(Advertisement::MissingAuthor) do
        act(PublishAdvertisement.new(advertisement_id, nil, content))
      end
    end

    test "can't be publish twice in a row" do
      advertisement_id = SecureRandom.uuid
      author_id = SecureRandom.uuid
      content = "Content: #{SecureRandom.hex}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id, content)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(PublishAdvertisement.new(advertisement_id, author_id, content))
      end
      assert_equal :published, error.current_state
      assert_equal :draft, error.desired_states
    end

    test "can't publish on hold advertisement" do
      advertisement_id = SecureRandom.uuid
      author_id = SecureRandom.uuid
      content = "Content: #{SecureRandom.hex}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id, content),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(PublishAdvertisement.new(advertisement_id, author_id, content))
      end
      assert_equal :on_hold, error.current_state
      assert_equal :draft, error.desired_states
    end

    test "can't publish suspended advertisement" do
      advertisement_id = SecureRandom.uuid
      author_id = SecureRandom.uuid
      content = "Content: #{SecureRandom.hex}"
      suspend_reason = "Reason: #{SecureRandom.hex}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id, content),
        SuspendAdvertisement.new(advertisement_id, suspend_reason)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(PublishAdvertisement.new(advertisement_id, author_id, content))
      end
      assert_equal :suspended, error.current_state
      assert_equal :draft, error.desired_states
    end

    test "can't publish expired advertisement" do
      advertisement_id = SecureRandom.uuid
      author_id = SecureRandom.uuid
      content = "Content: #{SecureRandom.hex}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id, content),
        ExpireAdvertisement.new(advertisement_id)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(PublishAdvertisement.new(advertisement_id, author_id, content))
      end
      assert_equal :expired, error.current_state
      assert_equal :draft, error.desired_states
    end
  end
end
