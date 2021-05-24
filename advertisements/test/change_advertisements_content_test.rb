require_relative 'test_helper'

module Advertisements
  class ChangeAdvertisementsContentTest < ActiveSupport::TestCase
    test 'change advertisement content' do
      advertisement_id = 51654
      repository = AdvertisementRepository.new

      repository.with_advertisement(advertisement_id) do |advertisement|
        advertisement.change_content("Astonishing new content!!!")
      end
    end
  end
end
