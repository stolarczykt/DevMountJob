module Advertisements
  class FakeDueDatePolicy
    FAKE_DUE_DATE = Time.now + (60 * 60)
    FAKE_NEW_DUE_DATE = Time.now + (60 * 60)
    FAKE_STOP_TIME = Time.now

    def call
      FAKE_DUE_DATE
    end

    def recalculate(prev_due_date, stopped_at)
      FAKE_NEW_DUE_DATE
    end

    def stop_time
      FAKE_STOP_TIME
    end
  end
end
