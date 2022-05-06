module Ranking

  class OnSubmitComplaint
    def call(command)
      repository = ComplaintRepository::new
      repository.with_complaint(command.complaint_id) do |complaint|
        complaint.submit_complaint(command.recruiter_id, command.candidate_id, command.note)
      end
    end
  end
end
