require_relative 'test_helper'

module Advertisements
  class ExpireAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'expire advertisement' do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id)
      )

      assert_events(
          stream,
          AdvertisementExpired.new
      ) do
        act(ExpireAdvertisement.new(advertisement_id))
      end
    end

    test "draft can't be expired" do
      advertisement_id = SecureRandom.random_number

      assert_raises(Advertisement::NotPublished) do
        act(ExpireAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be expired if suspended" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        SuspendAdvertisement.new(advertisement_id)
      )

      assert_raises(Advertisement::NotPublished) do
        act(ExpireAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be expired if on hold" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      assert_raises(Advertisement::NotPublished) do
        act(ExpireAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be expired if already expired" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        ExpireAdvertisement.new(advertisement_id)
      )

      assert_raises(Advertisement::AlreadyExpired) do
        act(ExpireAdvertisement.new(advertisement_id))
      end
    end
  end
end
