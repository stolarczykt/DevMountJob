module Ranking
  class Complaint
    include AggregateRoot

    MissingRecruiter = Class.new(StandardError)
    MissingCandidate = Class.new(StandardError)
    MissingNote = Class.new(StandardError)

    def initialize(id)
      raise ArgumentError if id.nil?
      @id = id
      @state = :initialized
    end

    def submit_complaint(recruiter_id, candidate_id, note)
      raise UnexpectedStateTransition.new(@state, :initialized) unless @state.equal?(:initialized)
      raise MissingRecruiter if recruiter_id.nil?
      raise MissingCandidate if candidate_id.nil?
      raise MissingNote if note.nil? || note.strip.empty?
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
