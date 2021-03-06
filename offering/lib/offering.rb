module Offering
  class OnMakeAnOffer
    def call(command)
      repository = OfferRepository::new
      repository.with_offer(command.offer_id) do |offer|
        offer.make(command.other_recruiters)
      end
    end
  end

  class OnRequestOffer
    def call(command)
      repository = OfferRepository::new
      repository.with_offer(command.offer_id) do |offer|
        offer.request(command.advertisement_id, command.recruiter_id, command.recipient_id, command.contact_details, command.expectations)
      end
    end
  end

  class OnRejectOffer
    def call(command)
      repository = OfferRepository::new
      repository.with_offer(command.offer_id) do |offer|
        offer.reject(command.requester_id)
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

  class OnAddAnOfferToFavorites
    def call(command)
      repository = OfferRepository::new
      repository.with_offer(command.offer_id) do |offer|
        offer.add_to_favorites(command.requester_id)
      end
    end
  end

  class OnRemoveAnOfferFromFavorites
    def call(command)
      repository = OfferRepository::new
      repository.with_offer(command.offer_id) do |offer|
        offer.remove_from_favorites(command.requester_id)
      end
    end
  end
end
