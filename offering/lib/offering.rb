module Offering
  class OnMakeAnOffer
    def call(command)
      repository = OfferRepository::new
      repository.with_offer(command.offer_id) do |offer|
        offer.make(command.advertisement_id, command.recruiter_id, command.recipient_id, command.contact_details)
      end
    end
  end

  class OnRejectOffer
    def call(command)
      repository = OfferRepository::new
      repository.with_offer(command.offer_id) do |offer|
        offer.reject
      end
    end
  end

  class OnReadAnOffer
    def call(command)
      repository = OfferRepository::new
      repository.with_offer(command.offer_id) do |offer|
        offer.read_by(command.requester_id)
      end
    end
  end
end
