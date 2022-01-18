module Advertisements
  class Advertisement
    include AggregateRoot

    NotPublished = Class.new(StandardError)
    AfterDueDate = Class.new(StandardError)
    UnexpectedStateTransition = Class.new(StandardError)
    NotAnAuthorOfAdvertisement = Class.new(StandardError)

    def initialize(id)
      @id = id
      @state = :draft
    end

    def publish(author_id, due_date)
      raise UnexpectedStateTransition.new("Publish allowed only from [#{:draft}], but was [#{@state}]") unless @state.equal?(:draft)
      apply AdvertisementPublished.new(
        data: {
          advertisement_id: @id,
          author_id: author_id,
          due_date: due_date
        }
      )
    end

    def put_on_hold(requester_id)
      raise UnexpectedStateTransition.new("Put on hold allowed only from [#{:published}], but was [#{@state}]") unless @state.equal?(:published)
      raise NotAnAuthorOfAdvertisement unless @author_id.equal?(requester_id)
      raise AfterDueDate if @due_date < Time.now
      apply AdvertisementPutOnHold.new(
        data: {
          advertisement_id: @id
        }
      )
    end

    def resume(requester_id)
      raise UnexpectedStateTransition.new("Resume allowed only from [#{:on_hold}], but was [#{@state}]") unless @state.equal?(:on_hold)
      raise NotAnAuthorOfAdvertisement unless @author_id.equal?(requester_id)
      apply AdvertisementResumed.new(
        data: {
          advertisement_id: @id
        }
      )
    end

    def suspend
      raise UnexpectedStateTransition.new("Suspend allowed only from [#{[:published, :on_hold].join(", ")}], but was [#{@state}]") unless [:published, :on_hold].include?(@state)
      apply AdvertisementSuspended.new(
        data: {
          advertisement_id: @id
        }
      )
    end

    def unblock
      raise UnexpectedStateTransition.new("Unblock allowed only from [#{:suspended}], but was [#{@state}]") unless @state.equal?(:suspended)
      apply AdvertisementUnblocked.new(
        data: {
          advertisement_id: @id
        }
      )
    end

    def expire
      raise UnexpectedStateTransition.new("Expire allowed only from [#{:published}], but was [#{@state}]") unless @state.equal?(:published)
      apply AdvertisementExpired.new(
        data: {
          advertisement_id: @id
        }
      )
    end

    def change_content(new_content, author_id)
      raise NotPublished unless @state.equal?(:published)
      raise NotAnAuthorOfAdvertisement unless @author_id.equal?(author_id)
      apply ContentHasChanged.new(
        data: {
          advertisement_id: @id,
          content: new_content
        }
      )
    end

    on AdvertisementPublished do |event|
      @state = :published
      @author_id = event.data[:author_id]
      @due_date = event.data[:due_date]
    end

    on AdvertisementExpired do |event|
      @state = :expired
    end

    on ContentHasChanged do |event|
    end

    on AdvertisementPutOnHold do |event|
      @state = :on_hold
    end

    on AdvertisementResumed do |event|
      @state = :published
    end

    on AdvertisementSuspended do |event|
      @state = :suspended
    end

    on AdvertisementUnblocked do |event|
      @state = :published
    end
  end
end
