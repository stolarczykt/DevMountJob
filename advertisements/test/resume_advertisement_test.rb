require_relative 'test_helper'

module Advertisements
  class ResumeAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'resume advertisement' do
      advertisement_id = 68456
      stream = "Advertisement$#{advertisement_id}"

      assert_events(
          stream,
          AdvertisementResumed.new
      ) do
        act(ResumeAdvertisement.new(advertisement_id))
      end
    end
  end
end
