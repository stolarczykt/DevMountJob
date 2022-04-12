require_relative 'test_helper'

module Payments
  class FinalizePaymentTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'payment finalized' do
      payment_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
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

      error = assert_raises(UnexpectedStateTransition) do
        act(FinalizePayment.new(payment_id))
      end
      assert_equal :initialized, error.current_state
      assert_equal :created, error.desired_states
    end

    test "can't finalize if payment failed" do
      payment_id = SecureRandom.uuid
      advertisement_id = SecureRandom.uuid
      amount = SecureRandom.random_number(1..100)
      reason = "Payment failed due to: not enough money"
      arrange(
        CreatePayment.new(payment_id, advertisement_id, amount),
        FailPayment.new(payment_id, reason)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(FinalizePayment.new(payment_id))
      end
      assert_equal :failed, error.current_state
      assert_equal :created, error.desired_states
    end
  end
end
