module Advertisements
  class Advertisement
    include AggregateRoot

    NotPublished = Class.new(StandardError)
    AfterDueDate = Class.new(StandardError)
    UnexpectedStateTransition = Class.new(StandardError)
    NotAnAuthorOfAdvertisement = Class.new(StandardError)
    ContentCantBeEmpty = Class.new(StandardError)

    def initialize(id, due_date_policy)
      @id = id
      @state = :draft
      @due_date_policy = due_date_policy
    end

    def publish(author_id, content)
      raise UnexpectedStateTransition.new("Publish allowed only from [#{:draft}], but was [#{@state}]") unless @state.equal?(:draft)
      raise ContentCantBeEmpty if content.nil? || content.empty?
      apply AdvertisementPublished.new(
        data: {
          advertisement_id: @id,
          author_id: author_id,
          content: content,
          due_date: @due_date_policy.call
        }
      )
    end

    def put_on_hold(requester_id)
      raise UnexpectedStateTransition.new("Put on hold allowed only from [#{:published}], but was [#{@state}]") unless @state.equal?(:published)
      raise NotAnAuthorOfAdvertisement unless @author_id.equal?(requester_id)
      stop_time = @due_date_policy.stop_time
      raise AfterDueDate if @due_date < stop_time
      apply AdvertisementPutOnHold.new(
        data: {
          advertisement_id: @id,
          stopped_at: stop_time
        }
      )
    end

    def resume(requester_id)
      raise UnexpectedStateTransition.new("Resume allowed only from [#{:on_hold}], but was [#{@state}]") unless @state.equal?(:on_hold)
      raise NotAnAuthorOfAdvertisement unless @author_id.equal?(requester_id)
      apply AdvertisementResumed.new(
        data: {
          advertisement_id: @id,
          due_date: @due_date_policy.recalculate(@due_date, @stopped_at)
        }
      )
    end

    def suspend(reason)
      raise UnexpectedStateTransition.new("Suspend allowed only from [#{[:published, :on_hold].join(", ")}], but was [#{@state}]") unless [:published, :on_hold].include?(@state)
      stopped_at = @state == :on_hold ? @stopped_at : @due_date_policy.stop_time
      apply AdvertisementSuspended.new(
        data: {
          advertisement_id: @id,
          reason: reason,
          stopped_at: stopped_at
        }
      )
    end

    def unblock
      raise UnexpectedStateTransition.new("Unblock allowed only from [#{:suspended}], but was [#{@state}]") unless @state.equal?(:suspended)
      apply AdvertisementUnblocked.new(
        data: {
          advertisement_id: @id,
          due_date: @due_date_policy.recalculate(@due_date, @stopped_at)
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
      raise ContentCantBeEmpty if new_content.nil? || new_content.empty?
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
      @stopped_at = event.data[:stopped_at]
    end

    on AdvertisementResumed do |event|
      @state = :published
      @due_date = event.data[:due_date]
    end

    on AdvertisementSuspended do |event|
      @state = :suspended
      @stopped_at = event.data[:stopped_at]
    end

    on AdvertisementUnblocked do |event|
      @state = :published
      @due_date = event.data[:due_date]
    end
  end
end
