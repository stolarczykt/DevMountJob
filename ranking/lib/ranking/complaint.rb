module Ranking
  class Complaint
    include AggregateRoot

    MissingRecruiter = Class.new(StandardError)
    MissingCandidate = Class.new(StandardError)
    MissingNote = Class.new(StandardError)
    MissingReason = Class.new(StandardError)

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

    def accept
      raise UnexpectedStateTransition.new(@state, :submitted) unless @state.equal?(:submitted)
      apply ComplaintAccepted.new(
        data: {
          complaint_id: @id
        }
      )
    end

    def expire
      raise UnexpectedStateTransition.new(@state, :submitted) unless @state.equal?(:submitted)
      apply ComplaintExpired.new(
        data: {
          complaint_id: @id
        }
      )
    end

    def reject(reason)
      raise UnexpectedStateTransition.new(@state, :submitted) unless @state.equal?(:submitted)
      raise MissingReason if reason.nil? || reason.strip.empty?
      apply ComplaintRejected.new(
        data: {
          complaint_id: @id,
          reason: reason
        }
      )
    end

    on ComplaintSubmitted do |_|
      @state = :submitted
    end

    on ComplaintAccepted do |_|
      @state = :accepted
    end

    on ComplaintExpired do |_|
      @state = :expired
    end

    on ComplaintRejected do |_|
      @state = :rejected
    end
  end
end
