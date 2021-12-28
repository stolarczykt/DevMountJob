module Advertisements
  class FakeDueDatePolicy
    FAKE_DUE_DATE = Time.new(2021, 12, 28)
    def call
      FAKE_DUE_DATE
    end
  end
end
