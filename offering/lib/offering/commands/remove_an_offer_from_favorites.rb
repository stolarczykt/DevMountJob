module Offering
  class RemoveAnOfferFromFavorites
    attr_accessor :offer_id, :requester_id
    def initialize(offer_id, requester_id)
      @offer_id = offer_id
      @requester_id = requester_id
    end
  end
end
