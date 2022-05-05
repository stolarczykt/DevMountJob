module Offering
  class MakeAnOffer
    attr_accessor :offer_id, :advertisement_id, :recruiter_id, :contact_details, :recipient_id, :other_recruiters, :expectations
    def initialize(offer_id, advertisement_id, recruiter_id, recipient_id, contact_details, other_recruiters, expectations)
      @offer_id = offer_id
      @advertisement_id = advertisement_id
      @recruiter_id = recruiter_id
      @recipient_id = recipient_id
      @contact_details = contact_details
      @other_recruiters = other_recruiters
      @expectations = expectations
    end
  end
end
