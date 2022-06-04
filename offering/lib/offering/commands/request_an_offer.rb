module Offering
  class RequestAnOffer
    attr_accessor :offer_id, :advertisement_id, :recruiter_id, :contact_details, :recipient_id, :expectations
    def initialize(offer_id, advertisement_id, recruiter_id, recipient_id, contact_details, expectations)
      @offer_id = offer_id
      @advertisement_id = advertisement_id
      @recruiter_id = recruiter_id
      @recipient_id = recipient_id
      @contact_details = contact_details
      @expectations = expectations
    end
  end
end
