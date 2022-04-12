module Payments
  class Payment
    include AggregateRoot

    MissingAdvertisement = Class.new(StandardError)
    MissingAmount = Class.new(StandardError)
    MissingFailReason = Class.new(StandardError)
    UnexpectedStateTransition = Class.new(StandardError)

    def initialize(id)
      raise ArgumentError if id.nil?
      @id = id
      @state = :initialized
    end

    def create_for(advertisement_id, amount)
      raise UnexpectedStateTransition.new("Create allowed only from [#{:initialized}], but was [#{@state}]") unless @state.equal?(:initialized)
      raise MissingAdvertisement if advertisement_id.nil?
      raise MissingAmount if amount <= 0
      apply PaymentCreated.new(
        data: {
          payment_id: @id,
          advertisement_id: advertisement_id,
          amount: amount
        }
      )
    end

    def finalize
      raise UnexpectedStateTransition.new("Finalize allowed only from [#{:created}], but was [#{@state}]") unless @state.equal?(:created)
      apply PaymentFinalized.new(
        data: {
          payment_id: @id
        }
      )
    end

    def fail_due_to(reason)
      raise UnexpectedStateTransition.new("Fail allowed only from [#{:created}], but was [#{@state}]") unless @state.equal?(:created)
      raise MissingFailReason if reason.nil? || reason.strip.empty?
      apply PaymentFailed.new(
        data: {
          payment_id: @id,
          reason: reason
        }
      )
    end

    on PaymentCreated do |_|
      @state = :created
    end

    on PaymentFinalized do |_|
      @state = :finalized
    end

    on PaymentFailed do |_|
      @state = :failed
    end
  end
end
