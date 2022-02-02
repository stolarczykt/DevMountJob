module Advertisements
  class DueDatePolicy
    def initialize(clock)
      @clock = clock
    end

    def call
      @clock.now + (60 * 60 * 24 * 14)
    end

    def recalculate(prev_due_date, stopped_at)
      prev_due_date + (@clock.now - stopped_at)
    end

    def stop_time
      @clock.now
    end
  end
end
