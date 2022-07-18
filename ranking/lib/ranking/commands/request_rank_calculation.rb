module Ranking
  class RequestRankCalculation
    attr_accessor :evaluation_id
    def initialize(evaluation_id)
      @evaluation_id = evaluation_id
    end
  end
end
