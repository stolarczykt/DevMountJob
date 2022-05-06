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
  end
end
