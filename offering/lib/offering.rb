module Offering
  class OnMakeAnOffer
    def call(command)
      repository = OfferRepository::new
      repository.with_offer(command.offer_id) do |offer|
        offer.make(command.advertisement_id, command.recruiter_id, command.contact_details)
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
end
