module Offering
  class MakeAnOffer
    attr_accessor :offer_id, :other_recruiters
    def initialize(offer_id, other_recruiters)
      @offer_id = offer_id
      @other_recruiters = other_recruiters
    end
  end
end
