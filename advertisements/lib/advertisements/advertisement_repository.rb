module Advertisements
  class AdvertisementRepository
    def initialize(
      event_store = Rails.configuration.event_store,
      due_date_policy = Rails.configuration.advertisement_due_date_policy.call
    )
      @repository = AggregateRoot::Repository.new(event_store)
      @due_date_policy = due_date_policy
    end

    def with_advertisement(advertisement_id, &block)
      stream_name = "Advertisement$#{advertisement_id}"
      repository.with_aggregate(Advertisement.new(advertisement_id, due_date_policy), stream_name, &block)
    end

    private
    attr_reader :repository
    attr_reader :due_date_policy
  end
end
