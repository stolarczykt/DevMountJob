module Advertisements
  class Advertisement
    include AggregateRoot

    AlreadyPublished = Class.new(StandardError)
    AlreadyResumed = Class.new(StandardError)
    AlreadyOnHold = Class.new(StandardError)
    AfterDueDate = Class.new(StandardError)
    AlreadyExpired = Class.new(StandardError)
    AlreadySuspended = Class.new(StandardError)
    NotPublished = Class.new(StandardError)
    NotADraft = Class.new(StandardError)
    NotAnAuthorOfAdvertisement = Class.new(StandardError)

    def initialize(id)
      @id = id
      @state = :draft
    end

    def publish(author_id, due_date)
      raise NotADraft unless @state.equal?(:draft)
      raise AlreadyPublished if @state.equal?(:published)
      apply AdvertisementPublished.new(
        data: {
          advertisement_id: @id,
          author_id: author_id,
          due_date: due_date
        }
      )
    end

    def put_on_hold(requester_id)
      raise AlreadyOnHold if @state.equal?(:on_hold)
      raise NotPublished unless @state.equal?(:published)
      raise NotAnAuthorOfAdvertisement unless @author_id.equal?(requester_id)
      raise AfterDueDate if @due_date < Time.now
      apply AdvertisementPutOnHold.new
    end

    def suspend
      raise AlreadySuspended if @state.equal?(:suspended)
      # raise NotPublished unless @state.equal?(:published)
      apply AdvertisementSuspended.new
    end

    def resume
      raise AlreadyResumed if @state.equal?(:resumed)
      apply AdvertisementResumed.new
    end

    def expire
      raise AlreadyExpired if @state.equal?(:expired)
      apply AdvertisementExpired.new
    end

    def change_content(new_content, author_id)
      raise NotPublished unless @state.equal?(:published)
      raise NotAnAuthorOfAdvertisement unless @author_id.equal?(author_id)
      apply ContentHasChanged.new(data: {content: new_content})
    end

    on AdvertisementPublished do |event|
      @state = :published
      @author_id = event.data[:author_id]
      @due_date = event.data[:due_date]
    end

    on AdvertisementResumed do |event|
      @state = :published
    end

    on AdvertisementExpired do |event|
      @state = :expired
    end

    on ContentHasChanged do |event|
    end

    on AdvertisementPutOnHold do |event|
      @state = :on_hold
    end

    on AdvertisementSuspended do |event|
      @state = :suspended
    end
  end
end
