module Payments
  class CreatePayment
    attr_accessor :advertisement_id
    attr_accessor :payment_id
    attr_accessor :amount
    def initialize(payment_id, advertisement_id, amount)
      @payment_id = payment_id
      @advertisement_id = advertisement_id
      @amount = amount
    end
  end
end
