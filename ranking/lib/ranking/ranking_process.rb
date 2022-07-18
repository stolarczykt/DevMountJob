module Ranking
  class RankingProcess < ApplicationJob
    queue_as :default

    class State < ActiveRecord::Base
      self.table_name = "ranking_process_states"
      serialize :data

      def self.get_by_evaluation_id(evaluation_id)
        transaction do
          lock.find_or_create_by(evaluation_id: evaluation_id).tap do |s|
            s.data ||= {
              evaluated: nil,
              completed: nil,
              recruiter_id: nil,
              candidate_id: nil,
              evaluation_note: nil
            }
            yield s
            s.save!
          end
        end
      end
    end

    def perform(serialized_event, command_bus = Rails.configuration.command_bus)
      event = YAML.load(serialized_event)
      State.get_by_evaluation_id(event.data.fetch(:evaluation_id)) do |state|
        case event
        when Ranking::RecruiterWasEvaluated
          state.data[:evaluated] = true
          state.data[:recruiter_id] = event.data.fetch(:recruiter_id)
          state.data[:candidate_id] = event.data.fetch(:candidate_id)
          state.data[:evaluation_note] = event.data.fetch(:evaluation_note)
          command_bus.call(
            RequestRankCalculation.new(event.data.fetch(:evaluation_id))
          )
        when Ranking::RankReceived
          if event.data.fetch(:score) < 50
            command_bus.call(
              SubmitComplaint.new(
                SecureRandom.uuid,
                state.data[:recruiter_id],
                state.data[:candidate_id],
                state.data[:evaluation_note]
              )
            )
          end
          state.data[:completed] = true
        else
          raise ArgumentError
        end
      end
    end
  end
end
