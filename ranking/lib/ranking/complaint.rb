module Ranking
  class Complaint
    include AggregateRoot

    MissingNote = Class.new(StandardError)

    def initialize(id)
      raise ArgumentError if id.nil?
      @id = id
      @state = :initialized
    end

    def submit_complaint(recruiter_id, candidate_id, note)
      raise UnexpectedStateTransition.new(@state, :initialized) unless @state.equal?(:initialized)
      apply ComplaintSubmitted.new(
        data: {
          complaint_id: @id,
          recruiter_id: recruiter_id,
          candidate_id: candidate_id,
          note: note
        }
      )
    end

    on ComplaintSubmitted do |_|
      @state = :submitted
    end
  end
end
