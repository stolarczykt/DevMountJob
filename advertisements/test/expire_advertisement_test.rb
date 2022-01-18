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
          AdvertisementExpired.new(
            data: {
              advertisement_id: advertisement_id
            }
          )
      ) do
        act(ExpireAdvertisement.new(advertisement_id))
      end
    end

    test "draft can't be expired" do
      advertisement_id = SecureRandom.random_number

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(ExpireAdvertisement.new(advertisement_id))
      end
      assert_equal "Expire allowed only from [published], but was [draft]", error.message
    end

    test "advertisement can't be expired if suspended" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        SuspendAdvertisement.new(advertisement_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(ExpireAdvertisement.new(advertisement_id))
      end
      assert_equal "Expire allowed only from [published], but was [suspended]", error.message
    end

    test "advertisement can't be expired if on hold" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(ExpireAdvertisement.new(advertisement_id))
      end
      assert_equal "Expire allowed only from [published], but was [on_hold]", error.message
    end

    test "advertisement can't be expired if already expired" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        ExpireAdvertisement.new(advertisement_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(ExpireAdvertisement.new(advertisement_id))
      end
      assert_equal "Expire allowed only from [published], but was [expired]", error.message
    end
  end
end
