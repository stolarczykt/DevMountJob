require_relative 'test_helper'

module Advertisements
  class SuspendAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test "suspend advertisement" do
      advertisement_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      author_id = SecureRandom.random_number
      arrange(PublishAdvertisement.new(advertisement_id, author_id))

      assert_events(
          stream,
          AdvertisementSuspended.new
      ) do
        act(SuspendAdvertisement.new(advertisement_id))
      end
    end

    test "suspend advertisement when on hold" do
      advertisement_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      assert_events(
          stream,
          AdvertisementSuspended.new
      ) do
        act(SuspendAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be suspended if draft" do
      advertisement_id = SecureRandom.random_number

      assert_raises(Advertisement::NotPublishedOrOnHold) do
        act(SuspendAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be suspended if expired" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        ExpireAdvertisement.new(advertisement_id)
      )

      assert_raises(Advertisement::NotPublishedOrOnHold) do
        act(SuspendAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be suspended if already suspended" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        SuspendAdvertisement.new(advertisement_id)
      )

      assert_raises(Advertisement::AlreadySuspended) do
        act(SuspendAdvertisement.new(advertisement_id))
      end
    end

  end
end
