module Advertisements
  class UnblockAdvertisement
    attr_accessor :advertisement_id
    def initialize(advertisement_id)
      @advertisement_id = advertisement_id
    end
  end
end
