require_relative 'test_helper'

module Advertisements
  class SuspendAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test "suspend advertisement" do
      advertisement_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      author_id = SecureRandom.random_number
      time_when_published = Time.now
      travel_in_time_to(time_when_published)
      arrange(PublishAdvertisement.new(advertisement_id, author_id))
      time_when_suspended = time_when_published + 100
      travel_in_time_to(time_when_suspended)

      assert_events(
          stream,
          AdvertisementSuspended.new(
            data: {
              advertisement_id: advertisement_id,
              stopped_at: time_when_suspended
            }
          )
      ) do
        act(SuspendAdvertisement.new(advertisement_id))
      end
    end

    test "suspend advertisement when on hold - take stop time from on hold" do
      advertisement_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      author_id = SecureRandom.random_number
      time_when_published = Time.now
      travel_in_time_to(time_when_published)
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id)
      )
      time_when_put_on_hold = time_when_published + 3600
      travel_in_time_to(time_when_put_on_hold)
      arrange(
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )
      travel_in_time_to(time_when_put_on_hold + 100)

      assert_events(
          stream,
          AdvertisementSuspended.new(
            data: {
              advertisement_id: advertisement_id,
              stopped_at: time_when_put_on_hold
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
