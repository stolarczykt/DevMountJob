module Payments
  class FailPayment
    attr_accessor :payment_id
    attr_accessor :reason
    def initialize(payment_id, reason)
      @payment_id = payment_id
      @reason = reason
    end
  end
end
