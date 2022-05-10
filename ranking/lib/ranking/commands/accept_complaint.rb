module Ranking
  class AcceptComplaint
    attr_accessor :complaint_id
    def initialize(complaint_id)
      @complaint_id = complaint_id
    end
  end
end
