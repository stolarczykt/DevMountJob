class FakeCommandBus
  attr_reader :received

  def call(command)
    @received = command
  end
end
