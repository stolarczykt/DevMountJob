module Payments
  class CreatePayment
    attr_accessor :advertisement_id
    attr_accessor :payment_id
    def initialize(payment_id, advertisement_id)
      @payment_id = payment_id
      @advertisement_id = advertisement_id
    end
  end
end
