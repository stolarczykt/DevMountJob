require_relative 'test_helper'

module Advertisements
  class ResumeAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'resume the advertisement' do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      due_date = FakeDueDatePolicy::FAKE_NEW_DUE_DATE
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      assert_events(
          stream,
          AdvertisementResumed.new(
            data: {
              advertisement_id: advertisement_id,
              due_date: due_date
            }
          )
      ) do
        act(ResumeAdvertisement.new(advertisement_id, author_id))
      end
    end

    test 'fail resume if not the author' do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      requester_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      assert_raises(Advertisement::NotAnAuthorOfAdvertisement) do
        act(ResumeAdvertisement.new(advertisement_id, requester_id))
      end
    end

    test "draft can't be resumed" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(ResumeAdvertisement.new(advertisement_id, author_id))
      end
      assert_equal "Resume allowed only from [on_hold], but was [draft]", error.message
    end

    test "advertisement can't be resumed if suspended" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        SuspendAdvertisement.new(advertisement_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(ResumeAdvertisement.new(advertisement_id, author_id))
      end
      assert_equal "Resume allowed only from [on_hold], but was [suspended]", error.message
    end

    test "advertisement can't be resumed if expired" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        ExpireAdvertisement.new(advertisement_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(ResumeAdvertisement.new(advertisement_id, author_id))
      end
      assert_equal "Resume allowed only from [on_hold], but was [expired]", error.message
    end

    test "advertisement can't be resumed if published" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(ResumeAdvertisement.new(advertisement_id, author_id))
      end
      assert_equal "Resume allowed only from [on_hold], but was [published]", error.message
    end
  end
end
