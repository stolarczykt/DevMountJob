module Payments
  class PaymentsRepository
    def initialize(
      event_store = Rails.configuration.event_store
    )
      @repository = AggregateRoot::Repository.new(event_store)
    end

    def with_payment(payment_id, &block)
      stream_name = "Payment$#{payment_id}"
      repository.with_aggregate(Payment.new(payment_id), stream_name, &block)
    end

    private
    attr_reader :repository
  end
end
