module Advertisements
  class FakeDueDatePolicy
    FAKE_DUE_DATE = Time.now + (60 * 60)
    def call
      FAKE_DUE_DATE
    end
  end
end
