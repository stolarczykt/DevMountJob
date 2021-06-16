module Advertisements
  class PublishAdvertisement
    attr_accessor :advertisement_id
    attr_accessor :author_id
    def initialize(advertisement_id, author_id)
      @advertisement_id = advertisement_id
      @author_id = author_id
    end
  end
end
