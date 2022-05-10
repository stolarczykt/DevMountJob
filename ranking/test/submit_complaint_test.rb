require_relative 'test_helper'

module Ranking
  class SubmitComplaintTest < ActiveSupport::TestCase
    include TestPlumbing

    test 'submit complaint' do
      complaint_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      candidate_id = SecureRandom.uuid
      note = "Random note: #{SecureRandom.hex}"
      stream = "Complaint$#{complaint_id}"

      assert_events(
          stream,
          ComplaintSubmitted.new(
              data: {
                complaint_id: complaint_id,
                recruiter_id: recruiter_id,
                candidate_id: candidate_id,
                note: note
              }
          )
      ) do
        act(SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, note))
      end
    end

    test "can't submit the same complaint twice" do
      complaint_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      candidate_id = SecureRandom.uuid
      note = "Random note: #{SecureRandom.hex}"
      arrange(
        SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, note)
      )

      error = assert_raises(UnexpectedStateTransition) do
        act(SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, note))
      end
      assert_equal :submitted, error.current_state
      assert_equal :initialized, error.desired_states
    end

    test 'fail when missing arguments' do
      complaint_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      candidate_id = SecureRandom.uuid
      note = "Random note: #{SecureRandom.hex}"

      assert_raises(Complaint::MissingRecruiter) do
        act(SubmitComplaint.new(complaint_id, nil, candidate_id, note))
      end

      assert_raises(Complaint::MissingCandidate) do
        act(SubmitComplaint.new(complaint_id, recruiter_id, nil, note))
      end

      assert_raises(Complaint::MissingNote) do
        act(SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, nil))
      end

      assert_raises(Complaint::MissingNote) do
        act(SubmitComplaint.new(complaint_id, recruiter_id, candidate_id, ""))
      end
    end
  end
end
