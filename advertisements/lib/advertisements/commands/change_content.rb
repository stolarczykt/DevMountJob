module Advertisements
  class ChangeContent
    attr_accessor :advertisement_id, :content, :author_id
    def initialize(advertisement_id, content, author_id)
      @advertisement_id = advertisement_id
      @content = content
      @author_id = author_id
    end
  end
end
