require_relative 'test_helper'

module Advertisements
  class ResumeAdvertisementTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'resume advertisement' do
      advertisement_id = 68456
      stream = "Advertisement$#{advertisement_id}"
      command_bus = Rails.configuration.command_bus

      assert_events(
          stream,
          AdvertisementResumed.new
      ) do
        command_bus.(ResumeAdvertisement.new(advertisement_id))
      end
    end
  end
end
