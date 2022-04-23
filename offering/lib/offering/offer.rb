module Offering
  class Offer
    include AggregateRoot

    MissingAdvertisement = Class.new(StandardError)
    MissingRecruiter = Class.new(StandardError)
    MissingRecipient = Class.new(StandardError)
    NotAnOfferRecipient = Class.new(StandardError)
    MissingContactDetails = Class.new(StandardError)

    def initialize(id)
      raise ArgumentError if id.nil?
      @id = id
      @state = :initialized
    end

    def make(advertisement_id, recruiter_id, recipient_id, contact_details)
      raise UnexpectedStateTransition.new(@state, :initialized) unless @state.equal?(:initialized)
      raise MissingAdvertisement if advertisement_id.nil?
      raise MissingRecruiter if recruiter_id.nil?
      raise MissingRecipient if recipient_id.nil?
      raise MissingContactDetails if contact_details.nil? || contact_details.strip.empty?
      apply OfferMade.new(
        data: {
          offer_id: @id,
          advertisement_id: advertisement_id,
          recruiter_id: recruiter_id,
          recipient_id: recipient_id,
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

    def read_by(user_id)
      raise UnexpectedStateTransition.new(@state, :made) unless @state.equal?(:made)
      raise NotAnOfferRecipient unless @recipient_id === user_id
      apply OfferRead.new(
        data: {
          offer_id: @id
        }
      )
    end

    def add_to_favorites(user_id)
      raise UnexpectedStateTransition.new(@state, :made) unless @state.equal?(:made)
      raise NotAnOfferRecipient unless @recipient_id === user_id
      apply OfferAddedToFavorites.new(
        data: {
          offer_id: @id
        }
      )
    end

    def remove_from_favorites(user_id)
      raise UnexpectedStateTransition.new(@state, :made) unless @state.equal?(:made)
      raise NotAnOfferRecipient unless @recipient_id === user_id
      apply OfferRemovedFromFavorites.new(
        data: {
          offer_id: @id
        }
      )
    end

    on OfferMade do |event|
      @state = :made
      @recipient_id = event.data[:recipient_id]
    end

    on OfferRejected do |_|
      @state = :rejected
    end

    on OfferRead do |_|
    end

    on OfferAddedToFavorites do |_|
    end

    on OfferRemovedFromFavorites do |_|
    end
  end
end
