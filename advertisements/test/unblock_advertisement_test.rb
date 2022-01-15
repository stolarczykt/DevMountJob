require_relative 'test_helper'

module Advertisements
  class UnblockAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'unblock advertisement' do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        SuspendAdvertisement.new(advertisement_id)
      )

      assert_events(
          stream,
          AdvertisementUnblocked.new(
            data: {
              advertisement_id: advertisement_id
            }
          )
      ) do
        act(UnblockAdvertisement.new(advertisement_id))
      end
    end

    test "draft can't be unblocked" do
      advertisement_id = SecureRandom.random_number

      assert_raises(Advertisement::NotSuspended) do
        act(UnblockAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be unblocked if on hold" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      assert_raises(Advertisement::NotSuspended) do
        act(UnblockAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be unblocked if expired" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        ExpireAdvertisement.new(advertisement_id)
      )

      assert_raises(Advertisement::NotSuspended) do
        act(UnblockAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be unblocked if published" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id)
      )

      assert_raises(Advertisement::NotSuspended) do
        act(UnblockAdvertisement.new(advertisement_id))
      end
    end
  end
end
