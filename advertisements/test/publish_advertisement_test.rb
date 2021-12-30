require_relative 'test_helper'

module Advertisements
  class PublishAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'publish advertisement' do
      advertisement_id = 68456
      author_id = 1256
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
  end
end
