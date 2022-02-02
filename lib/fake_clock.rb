class FakeClock
  def initialize(fake_time)
    @fake_time = fake_time
  end
  def now
    @fake_time
  end
end
