module Payments
  class Payment
    include AggregateRoot

    def initialize(id)
      raise ArgumentError if missing id
      @id = id
    end

    def pay_for(advertisement_id)
      raise MissingAuthor if missing advertisement_id
      apply PaymentCreated.new(
        data: {
          payment_id: @id,
          advertisement_id: advertisement_id
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
