require_relative 'test_helper'

module Payments
  class FinalizePaymentTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'payment finalized' do
      payment_id = SecureRandom.uuid
      advertisement_id = SecureRandom.random_number
      amount = SecureRandom.random_number(1..100)
      stream = "Payment$#{payment_id}"
      arrange(
        CreatePayment.new(payment_id, advertisement_id, amount)
      )

      assert_events(
          stream,
          PaymentFinalized.new(
              data: {
                payment_id: payment_id
              }
          )
      ) do
        act(FinalizePayment.new(payment_id))
      end
    end

    test "can't finalize if no payment created" do
      payment_id = SecureRandom.uuid

      error = assert_raises(Payment::UnexpectedStateTransition) do
        act(FinalizePayment.new(payment_id))
      end
      assert_equal "Finalize allowed only from [created], but was [initialized]", error.message
    end

    test "can't finalize if payment failed" do
      payment_id = SecureRandom.uuid
      advertisement_id = SecureRandom.random_number
      amount = SecureRandom.random_number(1..100)
      reason = "Payment failed due to: not enough money"
      arrange(
        CreatePayment.new(payment_id, advertisement_id, amount),
        FailPayment.new(payment_id, reason)
      )

      error = assert_raises(Payment::UnexpectedStateTransition) do
        act(FinalizePayment.new(payment_id))
      end
      assert_equal "Finalize allowed only from [created], but was [failed]", error.message
    end
  end
end
