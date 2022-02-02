module Advertisements
  class SuspendAdvertisement
    attr_accessor :advertisement_id
    attr_accessor :reason
    def initialize(advertisement_id, reason)
      @advertisement_id = advertisement_id
      @reason = reason
    end
  end
end
