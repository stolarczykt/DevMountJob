module Advertisements
  class AdvertisementRepository
    def initialize(
      event_store = Rails.configuration.event_store,
      clock = Rails.configuration.clock.call,
      due_date_policy = Rails.configuration.advertisement_due_date_policy.call
    )
      @repository = AggregateRoot::Repository.new(event_store)
      @clock = clock
      @due_date_policy = due_date_policy
    end

    def with_advertisement(advertisement_id, &block)
      stream_name = "Advertisement$#{advertisement_id}"
      repository.with_aggregate(Advertisement.new(advertisement_id, due_date_policy, clock), stream_name, &block)
    end

    private
    attr_reader :repository
    attr_reader :clock
    attr_reader :due_date_policy
  end
end
