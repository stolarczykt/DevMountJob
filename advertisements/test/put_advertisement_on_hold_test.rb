require_relative 'test_helper'

module Advertisements
  class PutAdvertisementOnHoldTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'put advertisement on hold by author' do
      advertisement_id = SecureRandom.random_number
      stream = "Advertisement$#{advertisement_id}"
      author_id = SecureRandom.random_number
      arrange(PublishAdvertisement.new(advertisement_id, author_id))

      assert_events(
          stream,
          AdvertisementPutOnHold.new(
            data: {
              advertisement_id: advertisement_id
            }
          )
      ) do
        act(PutAdvertisementOnHold.new(advertisement_id, author_id))
      end
    end

    test 'advertisement can be put on hold only by author' do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      random_requester_id = SecureRandom.random_number
      arrange(PublishAdvertisement.new(advertisement_id, author_id))

      assert_raises(Advertisement::NotAnAuthorOfAdvertisement) do
        act(PutAdvertisementOnHold.new(advertisement_id, random_requester_id))
      end
    end

    test "advertisement can't be put on hold if not published" do
      advertisement_id = SecureRandom.random_number
      random_requester_id = SecureRandom.random_number

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(PutAdvertisementOnHold.new(advertisement_id, random_requester_id))
      end
      assert_equal "Put on hold allowed only from [published], but was [draft]", error.message
    end

    test "advertisement can't be put on hold if suspended" do
      advertisement_id = SecureRandom.random_number
      random_requester_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        SuspendAdvertisement.new(advertisement_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(PutAdvertisementOnHold.new(advertisement_id, random_requester_id))
      end
      assert_equal "Put on hold allowed only from [published], but was [suspended]", error.message
    end

    test "advertisement can't be put on hold if expired" do
      advertisement_id = SecureRandom.random_number
      random_requester_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        ExpireAdvertisement.new(advertisement_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(PutAdvertisementOnHold.new(advertisement_id, random_requester_id))
      end
      assert_equal "Put on hold allowed only from [published], but was [expired]", error.message
    end

    test "advertisement can't be put on hold if already on hold" do
      advertisement_id = SecureRandom.random_number
      author_id = SecureRandom.random_number
      arrange(
        PublishAdvertisement.new(advertisement_id, author_id),
        PutAdvertisementOnHold.new(advertisement_id, author_id)
      )

      error = assert_raises(Advertisement::UnexpectedStateTransition) do
        act(PutAdvertisementOnHold.new(advertisement_id, author_id))
      end
      assert_equal "Put on hold allowed only from [published], but was [on_hold]", error.message
    end

  end
end
