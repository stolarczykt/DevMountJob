require_relative 'test_helper'

module Advertisements
  class PutAdvertisementOnHoldTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'put advertisement on hold by author' do
      advertisement_id = SecureRandom.uuid
      stream = "Advertisement$#{advertisement_id}"
      author_id = SecureRandom.uuid
      content = "Content: #{SecureRandom.hex}"
      time_when_published = Time.now
      travel_in_time_to(time_when_published)
      arrange(PublishAdvertisement.new(advertisement_id, author_id, content))
      time_when_put_on_hold = time_when_published + 3600
      travel_in_time_to(time_when_put_on_hold)

      assert_events(
          stream,
          AdvertisementPutOnHold.new(
            data: {
              advertisement_id: advertisement_id,
              stopped_at: time_when_put_on_hold
            }
          )
      ) do
        act(PutAdvertisementOnHold.new(advertisement_id, author_id))
      end
    end

    test "advertisement can't be put on hold after due date" do
      advertisement_id = SecureRandom.uuid
      author_id = SecureRandom.uuid
      content = "Content: #{SecureRandom.hex}"
      time_when_published = Time.now
      travel_in_time_to(time_when_published)
      arrange(PublishAdvertisement.new(advertisement_id, author_id, content))
      travel_in_time_to(time_when_published + (60 * 60 * 24 * 14) + 1)

      assert_raises(Advertisement::AfterDueDate) do
        act(PutAdvertisementOnHold.new(advertisement_id, author_id))
      end
    end

    test 'advertisement can be put on hold only by author' do
      advertisement_id = SecureRandom.uuid
      author_id = SecureRandom.uuid
      content = "Content: #{SecureRandom.hex}"
      random_requester_id = SecureRandom.uuid
      arrange(PublishAdvertisement.new(advertisement_id, author_id, content))

      assert_raises(Advertisement::NotAnAuthorOfAdvertisement) do
        act(PutAdvertisementOnHold.new(advertisement_id, random_requester_id))
      end
    end

    test "advertisement can't be put on hold if not published" do
      advertisement_id = SecureRandom.uuid
      random_requester_id = SecureRandom.uuid

      error = assert_raises(UnexpectedStateTransition) do
        act(PutAdvertisementOnHold.new(advertisement_id, random_requester_id))
      end
      assert_equal :draft, error.current_state
      assert_equal :published, error.desired_states
    end

    test "advertisement can't be put on hold if suspended" do
      advertisement_id = SecureRandom.uuid
      random_requester_id = SecureRandom.uuid
      content = "Content: #{SecureRandom.hex}"
      suspend_reason = "Reason: #{SecureRandom.hex}"
      author_id = SecureRandom.uuid
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id, content),
        SuspendAdvertisement.new(advertisement_id, suspend_reason)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(PutAdvertisementOnHold.new(advertisement_id, random_requester_id))
      end
      assert_equal :suspended, error.current_state
      assert_equal :published, error.desired_states
    end

    test "advertisement can't be put on hold if expired" do
      advertisement_id = SecureRandom.uuid
      random_requester_id = SecureRandom.uuid
      author_id = SecureRandom.uuid
      content = "Content: #{SecureRandom.hex}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id, content),
        ExpireAdvertisement.new(advertisement_id)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(PutAdvertisementOnHold.new(advertisement_id, random_requester_id))
      end
      assert_equal :expired, error.current_state
      assert_equal :published, error.desired_states
    end

    test "advertisement can't be put on hold if already on hold" do
      advertisement_id = SecureRandom.uuid
      author_id = SecureRandom.uuid
      content = "Content: #{SecureRandom.hex}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id, content),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(PutAdvertisementOnHold.new(advertisement_id, author_id))
      end
      assert_equal :on_hold, error.current_state
      assert_equal :published, error.desired_states
    end

  end
end
