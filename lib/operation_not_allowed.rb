class OperationNotAllowed < StandardError
  attr_reader :current_state
  def initialize(current_state)
    @current_state = current_state
    super("Operation not allowed in the #{current_state} state.")
  end
end
