require_relative 'test_helper'

module Payments
  class CreatePaymentTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'create payment' do
      payment_id = SecureRandom.random_number
      advertisement_id = SecureRandom.random_number
      stream = "Payment$#{payment_id}"

      assert_events(
          stream,
          PaymentCreated.new(
              data: {
                payment_id: payment_id,
                advertisement_id: advertisement_id
              }
          )
      ) do
        act(CreatePayment.new(payment_id, advertisement_id))
      end
    end
  end
end
