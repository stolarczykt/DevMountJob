module Ranking

  class OnSubmitComplaint
    def call(command)
      repository = ComplaintRepository::new
      repository.with_complaint(command.complaint_id) do |complaint|
        complaint.submit_complaint(command.recruiter_id, command.candidate_id, command.note)
      end
    end
  end

  class OnAcceptComplaint
    def call(command)
      repository = ComplaintRepository::new
      repository.with_complaint(command.complaint_id) do |complaint|
        complaint.accept
      end
    end
  end

  class OnExpireComplaint
    def call(command)
      repository = ComplaintRepository::new
      repository.with_complaint(command.complaint_id) do |complaint|
        complaint.expire
      end
    end
  end

  class OnRejectComplaint
    def call(command)
      repository = ComplaintRepository::new
      repository.with_complaint(command.complaint_id) do |complaint|
        complaint.reject(command.reason)
      end
    end
  end
end
