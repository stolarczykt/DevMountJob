module Ranking
  class SubmitComplaint
    attr_accessor :complaint_id
    attr_accessor :recruiter_id
    attr_accessor :candidate_id
    attr_accessor :note
    def initialize(complaint_id, recruiter_id, candidate_id, note)
      @complaint_id = complaint_id
      @recruiter_id = recruiter_id
      @candidate_id = candidate_id
      @note = note
    end
  end
end
