require_relative 'test_helper'

module Advertisements
  class ChangeAdvertisementsContentTest < ActiveSupport::TestCase
    test 'change advertisement content' do
      stream_name = "Advertisement$123"
      repository = AggregateRoot::Repository.new

      repository.with_aggregate(Advertisement.new, stream_name) do |advertisement|
        advertisement.change_content("Astonishing new content!!!")
      end
    end
  end
end
