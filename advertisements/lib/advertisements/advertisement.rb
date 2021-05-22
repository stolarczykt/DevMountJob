module Advertisements
  class Advertisement
    include AggregateRoot

    def initialize
      @content = ''
    end

    def content
      @content
    end

    def change_content(new_content)
      apply ContentHasChanged.new(data: {content: new_content})
    end

    def apply_content_has_changed(event)
      @content = event.data.fetch(:content)
    end
  end
end
