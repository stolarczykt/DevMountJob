require_relative '../lib/offering'
require_relative '../../test/test_helper'

module OfferingTestPlumbing
  include TestPlumbing

  def arrange_making_an_offer
    offer_data = arrange_request_an_offer
    arrange(
      Offering::MakeAnOffer.new(
        offer_data.offer_id,
        offer_data.other_recruiters
      )
    )
    offer_data
  end

  def arrange_request_an_offer
    offer_data = TestOfferData.new
    arrange(
      Offering::RequestAnOffer.new(
        offer_data.offer_id,
        offer_data.advertisement_id,
        offer_data.recruiter_id,
        offer_data.recipient_id,
        offer_data.contact_details,
        offer_data.expectations
      )
    )
    offer_data
  end

  class TestOfferData
    attr_accessor :offer_id, :advertisement_id, :recruiter_id, :recipient_id, :contact_details, :other_recruiters, :expectations, :stream
    def initialize
      @offer_id = SecureRandom.uuid
      @advertisement_id = SecureRandom.uuid
      @recruiter_id = SecureRandom.uuid
      @recipient_id = SecureRandom.uuid
      @contact_details = "Contact details: #{SecureRandom.alphanumeric(100)}"
      @other_recruiters = []
      @expectations = []
      @stream = "Offer$#{@offer_id}"
    end
  end
end