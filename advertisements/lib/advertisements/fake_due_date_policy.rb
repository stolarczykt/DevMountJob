module Advertisements
  class FakeDueDatePolicy
    PUBLISH_FOR_SECONDS = 60 * 60 * 24
    AFTER_DUE_DATE = PUBLISH_FOR_SECONDS + 60

    def initialize(clock)
      @clock = clock
    end

    def call
      @clock.now + PUBLISH_FOR_SECONDS
    end

    def recalculate(prev_due_date, stopped_at)
      prev_due_date + (@clock.now - stopped_at)
    end
  end
end
