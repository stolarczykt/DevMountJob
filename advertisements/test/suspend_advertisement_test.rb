require_relative 'test_helper'

module Advertisements
  class SuspendAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test "suspend advertisement" do
      advertisement_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      author_id = SecureRandom.random_number
      stop_time = FakeDueDatePolicy::FAKE_STOP_TIME
      arrange(PublishAdvertisement.new(advertisement_id, author_id))

      assert_events(
          stream,
          AdvertisementSuspended.new(
            data: {
              advertisement_id: advertisement_id,
              stopped_at: stop_time
            }
          )
      ) do
        act(SuspendAdvertisement.new(advertisement_id))
      end
    end

    test "suspend advertisement when on hold" do
      advertisement_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      author_id = SecureRandom.random_number
      stop_time = FakeDueDatePolicy::FAKE_STOP_TIME
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      assert_events(
          stream,
          AdvertisementSuspended.new(
            data: {
              advertisement_id: advertisement_id,
              stopped_at: stop_time
            }
          )
      ) do
        act(SuspendAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be suspended if draft" do
      advertisement_id = SecureRandom.random_number

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(SuspendAdvertisement.new(advertisement_id))
      end
      assert_equal "Suspend allowed only from [published, on_hold], but was [draft]", error.message
    end

    test "advertisement can't be suspended if expired" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        ExpireAdvertisement.new(advertisement_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(SuspendAdvertisement.new(advertisement_id))
      end
      assert_equal "Suspend allowed only from [published, on_hold], but was [expired]", error.message
    end

    test "advertisement can't be suspended if already suspended" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        SuspendAdvertisement.new(advertisement_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(SuspendAdvertisement.new(advertisement_id))
      end
      assert_equal "Suspend allowed only from [published, on_hold], but was [suspended]", error.message
    end
  end
end
