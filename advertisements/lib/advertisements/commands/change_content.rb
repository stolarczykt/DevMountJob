module Advertisements
  class ChangeContent
    attr_accessor :advertisement_id, :content
    def initialize(advertisement_id, content)
      @advertisement_id = advertisement_id
      @content = content
    end
  end
end
