require_relative 'test_helper'

module Payments
  class CreatePaymentTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'create payment' do
      payment_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      amount = SecureRandom.random_number(1..100)
      stream = "Payment$#{payment_id}"

      assert_events(
          stream,
          PaymentCreated.new(
              data: {
                payment_id: payment_id,
                advertisement_id: advertisement_id,
                amount: amount
              }
          )
      ) do
        act(CreatePayment.new(payment_id, advertisement_id, amount))
      end
    end

    test 'fail when missing advertisement or amount' do
      payment_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      amount = SecureRandom.random_number(1..100)

      assert_raises(Payment::MissingAdvertisement) do
        act(CreatePayment.new(payment_id, "", amount))
      end

      assert_raises(Payment::MissingAmount) do
        act(CreatePayment.new(payment_id, advertisement_id, 0))
      end
    end
  end
end
