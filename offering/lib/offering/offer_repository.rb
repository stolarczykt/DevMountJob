module Offering
  class OfferRepository
    def initialize(
      event_store = Rails.configuration.event_store
    )
      @repository = AggregateRoot::Repository.new(event_store)
    end

    def with_offer(offer_id, &block)
      stream_name = "Offer$#{offer_id}"
      repository.with_aggregate(Offer.new(offer_id), stream_name, &block)
    end

    private
    attr_reader :repository
  end
end
