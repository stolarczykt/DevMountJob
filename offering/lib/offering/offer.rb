module Offering
  class Offer
    include AggregateRoot

    MissingAdvertisement = Class.new(StandardError)
    MissingRecruiter = Class.new(StandardError)
    MissingContactDetails = Class.new(StandardError)

    def initialize(id)
      raise ArgumentError if id.nil?
      @id = id
      @state = :initialized
    end

    def make(advertisement_id, recruiter_id, contact_details)
      raise UnexpectedStateTransition.new(@state, :initialized) unless @state.equal?(:initialized)
      raise MissingAdvertisement if advertisement_id.nil?
      raise MissingRecruiter if recruiter_id.nil?
      raise MissingContactDetails if contact_details.nil? || contact_details.strip.empty?
      apply OfferMade.new(
        data: {
          offer_id: @id,
          advertisement_id: advertisement_id,
          recruiter_id: recruiter_id,
          contact_details: contact_details
        }
      )
    end

    def reject
      raise UnexpectedStateTransition.new(@state, :made) unless @state.equal?(:made)
      apply OfferRejected.new(
        data: {
          offer_id: @id
        }
      )
    end

    on OfferMade do |event|
      @state = :made
    end

    on OfferRejected do |event|
      @state = :rejected
    end
  end
end
