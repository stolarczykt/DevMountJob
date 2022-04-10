require_relative 'test_helper'

module Payments
  class FailPaymentTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'payment failed' do
      payment_id = SecureRandom.uuid
      advertisement_id = SecureRandom.random_number
      amount = SecureRandom.random_number(1..100)
      reason = "Payment failed due to: not enough money"
      stream = "Payment$#{payment_id}"
      arrange(
        CreatePayment.new(payment_id, advertisement_id, amount)
      )

      assert_events(
          stream,
          PaymentFailed.new(
              data: {
                payment_id: payment_id,
                reason: reason
              }
          )
      ) do
        act(FailPayment.new(payment_id, reason))
      end
    end

    test 'fail when missing reason' do
      payment_id = SecureRandom.uuid
      advertisement_id = SecureRandom.random_number
      amount = SecureRandom.random_number(1..100)
      arrange(
        CreatePayment.new(payment_id, advertisement_id, amount)
      )

      assert_raises(Payment::MissingFailReason) do
        act(FailPayment.new(payment_id, ""))
      end
    end

    test "can't fail if no payment created" do
      payment_id = SecureRandom.uuid
      reason = "Payment failed due to: not enough money"

      error = assert_raises(Payment::UnexpectedStateTransition) do
        act(FailPayment.new(payment_id, reason))
      end
      assert_equal "Fail allowed only from [created], but was [initialized]", error.message
    end

    test "can't fail if payment finalized" do
      payment_id = SecureRandom.uuid
      advertisement_id = SecureRandom.random_number
      amount = SecureRandom.random_number(1..100)
      reason = "Payment failed due to: not enough money"
      arrange(
        CreatePayment.new(payment_id, advertisement_id, amount),
        FinalizePayment.new(payment_id)
      )

      error = assert_raises(Payment::UnexpectedStateTransition) do
        act(FailPayment.new(payment_id, reason))
      end
      assert_equal "Fail allowed only from [created], but was [finalized]", error.message
    end
  end
end
