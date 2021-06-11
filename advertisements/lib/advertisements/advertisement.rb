module Advertisements
  class Advertisement
    include AggregateRoot

    AlreadyPublished = Class.new(StandardError)
    NotPublished = Class.new(StandardError)

    def publish
      raise AlreadyPublished if @state.equal?(:published)
      apply AdvertisementPublished.new
    end

    def change_content(new_content)
      raise NotPublished unless @state.equal?(:published)
      apply ContentHasChanged.new(data: {content: new_content})
    end

    def apply_advertisement_published(event)
      @state = :published
    end

    def apply_content_has_changed(event)
    end
  end
end
