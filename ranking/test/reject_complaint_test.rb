require_relative 'test_helper'

module Ranking
  class RejectComplaintTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'reject complaint' do
      complaint_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      candidate_id = SecureRandom.uuid
      note = "Random note: #{SecureRandom.hex}"
      reason = "Candidate is a bot that tries to downgrade all recruiters."
      stream = "Complaint$#{complaint_id}"
      arrange(
        SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, note)
      )

      assert_events(
        stream,
        ComplaintRejected.new(
          data: {
            complaint_id: complaint_id,
            reason: reason
          }
        )
      ) do
        act(RejectComplaint.new(complaint_id, reason))
      end
    end

    test "can't reject if no complaint submitted" do
      complaint_id = SecureRandom.uuid
      reason = "Candidate is a bot that tries to downgrade all recruiters."

      error = assert_raises(UnexpectedStateTransition) do
        act(RejectComplaint.new(complaint_id, reason))
      end
      assert_equal :initialized, error.current_state
      assert_equal :submitted, error.desired_states
    end

    test "can't reject if complaint expired" do
      complaint_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      candidate_id = SecureRandom.uuid
      note = "Random note: #{SecureRandom.hex}"
      reason = "Candidate is a bot that tries to downgrade all recruiters."
      arrange(
        SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, note),
        ExpireComplaint.new(complaint_id)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(RejectComplaint.new(complaint_id, reason))
      end
      assert_equal :expired, error.current_state
      assert_equal :submitted, error.desired_states
    end

    test "can't reject if complaint accepted" do
      complaint_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      candidate_id = SecureRandom.uuid
      note = "Random note: #{SecureRandom.hex}"
      reason = "Candidate is a bot that tries to downgrade all recruiters."
      arrange(
        SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, note),
        AcceptComplaint.new(complaint_id)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(RejectComplaint.new(complaint_id, reason))
      end
      assert_equal :accepted, error.current_state
      assert_equal :submitted, error.desired_states
    end

    test "can't reject if missing reason" do
      complaint_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      candidate_id = SecureRandom.uuid
      note = "Random note: #{SecureRandom.hex}"
      arrange(
        SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, note)
      )

      assert_raises(Complaint::MissingReason) do
        act(RejectComplaint.new(complaint_id, nil))
      end

      assert_raises(Complaint::MissingReason) do
        act(RejectComplaint.new(complaint_id, ""))
      end
    end

  end
end
