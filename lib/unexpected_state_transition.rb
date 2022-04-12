class UnexpectedStateTransition < StandardError
  attr_reader :current_state, :desired_states
  def initialize(current_state, desired_states)
    @current_state = current_state
    @desired_states = desired_states
    super("Requires: #{desired_states} state(s), to execute this operation, but was: #{current_state}.")
  end
end
