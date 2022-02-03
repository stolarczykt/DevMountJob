module Advertisements
  class PublishAdvertisement
    attr_accessor :advertisement_id
    attr_accessor :author_id
    attr_accessor :content
    def initialize(advertisement_id, author_id, content)
      @advertisement_id = advertisement_id
      @author_id = author_id
      @content = content
    end
  end
end
