module Ranking
  class ExpireComplaint
    attr_accessor :complaint_id
    def initialize(complaint_id)
      @complaint_id = complaint_id
    end
  end
end
