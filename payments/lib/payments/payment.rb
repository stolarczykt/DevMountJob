module Payments
  class Payment
    include AggregateRoot

    MissingAdvertisement = Class.new(StandardError)
    MissingAmount = Class.new(StandardError)

    def initialize(id)
      raise ArgumentError if missing id
      @id = id
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

    on PaymentCreated do |event|
      @advertisement_id = event.data[:advertisement_id]
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
