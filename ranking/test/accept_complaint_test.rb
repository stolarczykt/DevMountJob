require_relative 'test_helper'

module Ranking
  class AcceptComplaintTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'accept complaint' do
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
        ComplaintAccepted.new(
          data: {
            complaint_id: complaint_id
          }
        )
      ) do
        act(AcceptComplaint.new(complaint_id))
      end
    end

    test "can't accept if no complaint submitted" do
      complaint_id = SecureRandom.uuid

      error = assert_raises(UnexpectedStateTransition) do
        act(AcceptComplaint.new(complaint_id))
      end
      assert_equal :initialized, error.current_state
      assert_equal :submitted, error.desired_states
    end

    test "can't accept if complaint rejected" do
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
        act(AcceptComplaint.new(complaint_id))
      end
      assert_equal :rejected, error.current_state
      assert_equal :submitted, error.desired_states
    end

    test "can't accept if complaint expired" do
      complaint_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      candidate_id = SecureRandom.uuid
      note = "Random note: #{SecureRandom.hex}"
      arrange(
        SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, note),
        ExpireComplaint.new(complaint_id)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(AcceptComplaint.new(complaint_id))
      end
      assert_equal :expired, error.current_state
      assert_equal :submitted, error.desired_states
    end
  end
end
