require_relative 'test_helper'

module Advertisements
  class ResumeAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'resume advertisement' do
      advertisement_id = 68456
      author_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      assert_events(
          stream,
          AdvertisementResumed.new
      ) do
        act(ResumeAdvertisement.new(advertisement_id))
      end
    end

    test "draft can't be resumed" do
      advertisement_id = SecureRandom.random_number

      assert_raises(Advertisement::NotOnHold) do
        act(ResumeAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be resumed if suspended" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        SuspendAdvertisement.new(advertisement_id)
      )

      assert_raises(Advertisement::NotOnHold) do
        act(ResumeAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be resumed if expired" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        ExpireAdvertisement.new(advertisement_id)
      )

      assert_raises(Advertisement::NotOnHold) do
        act(ResumeAdvertisement.new(advertisement_id))
      end
    end

    test "advertisement can't be resumed if published" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id)
      )

      assert_raises(Advertisement::NotOnHold) do
        act(ResumeAdvertisement.new(advertisement_id))
      end
    end
  end
end
