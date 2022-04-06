module Payments

  class OnCreatePayment
    def call(command)
      repository = PaymentsRepository::new
      repository.with_payment(command.payment_id) do |payment|
        payment.pay_for(command.advertisement_id, command.amount)
      end
    end
  end

  class OnFailPayment
    def call(command)
      repository = PaymentsRepository::new
      repository.with_payment(command.payment_id) do |payment|
        payment.fail_due_to(command.reason)
      end
    end
  end
end
