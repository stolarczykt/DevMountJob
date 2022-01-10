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

      assert_raises(Advertisement::NotADraft) do
        act(PublishAdvertisement.new(advertisement_id, author_id))
      end
    end

    test "can't publish on hold advertisement" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      assert_raises(Advertisement::NotADraft) do
        act(PublishAdvertisement.new(advertisement_id, author_id))
      end
    end

    test "can't publish suspended advertisement" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        SuspendAdvertisement.new(advertisement_id)
      )

      assert_raises(Advertisement::NotADraft) do
        act(PublishAdvertisement.new(advertisement_id, author_id))
      end
    end

    test "can't publish expired advertisement" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        ExpireAdvertisement.new(advertisement_id)
      )

      assert_raises(Advertisement::NotADraft) do
        act(PublishAdvertisement.new(advertisement_id, author_id))
      end
    end
  end
end
