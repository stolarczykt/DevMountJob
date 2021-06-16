module Advertisements
  class AdvertisementRepository
    def initialize(event_store = Rails.configuration.event_store)
      @repository = AggregateRoot::Repository.new(event_store)
    end

    def with_advertisement(advertisement_id, &block)
      stream_name = "Advertisement$#{advertisement_id}"
      repository.with_aggregate(Advertisement.new(advertisement_id), stream_name, &block)
    end

    private
    attr_reader :repository
  end
end
