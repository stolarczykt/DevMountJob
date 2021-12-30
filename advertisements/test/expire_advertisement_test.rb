require_relative 'test_helper'

module Advertisements
  class ExpireAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'expire advertisement' do
      advertisement_id = 68456
      stream = "Advertisement$#{advertisement_id}"

      assert_events(
          stream,
          AdvertisementExpired.new
      ) do
        act(ExpireAdvertisement.new(advertisement_id))
      end
    end
  end
end
