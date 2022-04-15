module Offering
  class MakeAnOffer
    attr_accessor :offer_id, :advertisement_id, :recruiter_id, :contact_details
    def initialize(offer_id, advertisement_id, recruiter_id, contact_details)
      @offer_id = offer_id
      @advertisement_id = advertisement_id
      @recruiter_id = recruiter_id
      @contact_details = contact_details
    end
  end
end
