module Advertisements
  class DueDatePolicy
    def call
      Time.now + (60 * 60 * 24 * 14)
    end
  end
end
