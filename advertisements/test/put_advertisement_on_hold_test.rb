require_relative 'test_helper'

module Advertisements
  class PutAdvertisementOnHoldTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'put advertisement on hold' do
      advertisement_id = 68456
      stream = "Advertisement$#{advertisement_id}"
      command_bus = Rails.configuration.command_bus

      assert_events(
          stream,
          AdvertisementPutOnHold.new
      ) do
        command_bus.(PutAdvertisementOnHold.new(advertisement_id))
      end
    end
  end
end
