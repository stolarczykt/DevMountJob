module Advertisements
  class PutAdvertisementOnHold
    attr_accessor :advertisement_id
    attr_accessor :requester_id
    def initialize(advertisement_id, requester_id)
      @advertisement_id = advertisement_id
      @requester_id = requester_id
    end
  end
end
