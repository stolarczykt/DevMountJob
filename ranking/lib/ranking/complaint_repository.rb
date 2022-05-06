module Ranking
  class ComplaintRepository
    def initialize(
      event_store = Rails.configuration.event_store
    )
      @repository = AggregateRoot::Repository.new(event_store)
    end

    def with_complaint(complaint_id, &block)
      stream_name = "Complaint$#{complaint_id}"
      repository.with_aggregate(Complaint.new(complaint_id), stream_name, &block)
    end

    private
    attr_reader :repository
  end
end
