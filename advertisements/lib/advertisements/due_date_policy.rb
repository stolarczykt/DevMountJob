module Advertisements
  class DueDatePolicy
    def call
      Time.now + (60 * 60 * 24 * 14)
    end

    def recalculate(prev_due_date, stopped_at)
      prev_due_date + (Time.now - stopped_at)
    end

    def stop_time
      Time.now
    end
  end
end
