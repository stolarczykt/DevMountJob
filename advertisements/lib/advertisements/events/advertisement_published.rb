module Advertisements
  class AdvertisementPublished < RailsEventStore::Event
    attr_accessor :advertisement_id
    attr_accessor :author_id
  end
end
