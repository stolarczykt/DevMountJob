module Ranking
  class RejectComplaint
    attr_accessor :complaint_id
    attr_accessor :reason
    def initialize(complaint_id, reason)
      @complaint_id = complaint_id
      @reason = reason
    end
  end
end
