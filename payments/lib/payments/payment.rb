module Payments
  class Payment
    include AggregateRoot

    MissingAdvertisement = Class.new(StandardError)
    MissingAmount = Class.new(StandardError)
    MissingFailReason = Class.new(StandardError)
    UnexpectedStateTransition = Class.new(StandardError)

    def initialize(id)
      raise ArgumentError if missing id
      @id = id
      @state = :initialized
    end

    def pay_for(advertisement_id, amount)
      raise MissingAdvertisement if missing advertisement_id
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
      raise MissingFailReason if missing reason
      apply PaymentFailed.new(
        data: {
          payment_id: @id,
          reason: reason
        }
      )
    end

    on PaymentCreated do |event|
      @state = :created
      @advertisement_id = event.data[:advertisement_id]
    end

    on PaymentFinalized do |event|
      @state = :finalized
    end

    on PaymentFailed do |event|
      @state = :failed
      @reason = event.data[:reason]
    end

    private

    def missing(value)
      case value
      in String
        value.nil? || value.strip.empty?
      else
        value.nil?
      end
    end
  end
end
