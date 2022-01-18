require_relative 'test_helper'

module Advertisements
  class PublishAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'publish advertisement' do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      due_date = FakeDueDatePolicy::FAKE_DUE_DATE

      assert_events(
          stream,
          AdvertisementPublished.new(
              data: {
                  advertisement_id: advertisement_id,
                  author_id: author_id,
                  due_date: due_date
              }
          )
      ) do
        act(PublishAdvertisement.new(advertisement_id, author_id))
      end
    end

    test "can't be publish twice in a row" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(PublishAdvertisement.new(advertisement_id, author_id))
      end
      assert_equal "Publish allowed only from [draft], but was [published]", error.message
    end

    test "can't publish on hold advertisement" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(PublishAdvertisement.new(advertisement_id, author_id))
      end
      assert_equal "Publish allowed only from [draft], but was [on_hold]", error.message
    end

    test "can't publish suspended advertisement" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        SuspendAdvertisement.new(advertisement_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(PublishAdvertisement.new(advertisement_id, author_id))
      end
      assert_equal "Publish allowed only from [draft], but was [suspended]", error.message
    end

    test "can't publish expired advertisement" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        ExpireAdvertisement.new(advertisement_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(PublishAdvertisement.new(advertisement_id, author_id))
      end
      assert_equal "Publish allowed only from [draft], but was [expired]", error.message
    end
  end
end
