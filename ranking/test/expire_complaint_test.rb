require_relative 'test_helper'

module Ranking
  class ExpireComplaintTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'expire complaint' do
      complaint_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      candidate_id = SecureRandom.uuid
      note = "Random note: #{SecureRandom.hex}"
      stream = "Complaint$#{complaint_id}"
      arrange(
        SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, note)
      )

      assert_events(
        stream,
        ComplaintExpired.new(
          data: {
            complaint_id: complaint_id
          }
        )
      ) do
        act(ExpireComplaint.new(complaint_id))
      end
    end

    test "can't expire if no complaint submitted" do
      complaint_id = SecureRandom.uuid

      error = assert_raises(UnexpectedStateTransition) do
        act(ExpireComplaint.new(complaint_id))
      end
      assert_equal :initialized, error.current_state
      assert_equal :submitted, error.desired_states
    end

    test "can't expire if complaint rejected" do
      complaint_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      candidate_id = SecureRandom.uuid
      note = "Random note: #{SecureRandom.hex}"
      reason = "Candidate is a bot that tries to downgrade all recruiters."
      arrange(
        SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, note),
        RejectComplaint.new(complaint_id, reason)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(ExpireComplaint.new(complaint_id))
      end
      assert_equal :rejected, error.current_state
      assert_equal :submitted, error.desired_states
    end

    test "can't expire if complaint accepted" do
      complaint_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      candidate_id = SecureRandom.uuid
      note = "Random note: #{SecureRandom.hex}"
      arrange(
        SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, note),
        AcceptComplaint.new(complaint_id)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(ExpireComplaint.new(complaint_id))
      end
      assert_equal :accepted, error.current_state
      assert_equal :submitted, error.desired_states
    end
  end
end
