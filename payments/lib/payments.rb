module Payments

  class OnCreatePayment
    def call(command)
      repository = PaymentsRepository::new
      repository.with_payment(command.payment_id) do |payment|
        payment.pay_for(command.advertisement_id)
      end
    end
  end
end
