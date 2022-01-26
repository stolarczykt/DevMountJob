require_relative 'test_helper'

module Advertisements
  class UnblockAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'unblock advertisement' do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      due_date = FakeDueDatePolicy::FAKE_NEW_DUE_DATE
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        SuspendAdvertisement.new(advertisement_id)
      )

      assert_events(
          stream,
          AdvertisementUnblocked.new(
            data: {
              advertisement_id: advertisement_id,
              due_date: due_date
            }
          )
      ) do
        act(UnblockAdvertisement.new(advertisement_id))
      end
    end

    test "draft can't be unblocked" do
      advertisement_id = SecureRandom.random_number

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(UnblockAdvertisement.new(advertisement_id))
      end
      assert_equal "Unblock allowed only from [suspended], but was [draft]", error.message
    end

    test "advertisement can't be unblocked if on hold" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(UnblockAdvertisement.new(advertisement_id))
      end
      assert_equal "Unblock allowed only from [suspended], but was [on_hold]", error.message
    end

    test "advertisement can't be unblocked if expired" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        ExpireAdvertisement.new(advertisement_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(UnblockAdvertisement.new(advertisement_id))
      end
      assert_equal "Unblock allowed only from [suspended], but was [expired]", error.message
    end

    test "advertisement can't be unblocked if published" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(UnblockAdvertisement.new(advertisement_id))
      end
      assert_equal "Unblock allowed only from [suspended], but was [published]", error.message
    end
  end
end
