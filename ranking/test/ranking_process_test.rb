require_relative 'test_helper'
require 'securerandom'

module Ranking
  class RankingProcessTest < ActiveSupport::TestCase

    test 'request rank calculation when evaluation submitted' do
      command_bus = FakeCommandBus.new
      process = RankingProcess.new
      evaluation_id = SecureRandom.uuid

      process.perform(
        YAML.dump(Ranking::RecruiterWasEvaluated.new(
          data: {
            evaluation_id: evaluation_id,
            recruiter_id: SecureRandom.uuid,
            candidate_id: SecureRandom.uuid,
            evaluation_note: "Evaluation note: #{SecureRandom.alphanumeric(100)}"
          }
        )), command_bus
      )

      command = command_bus.received
      assert_instance_of(Ranking::RequestRankCalculation, command)
      assert_equal(command.evaluation_id, evaluation_id)
    end

    test 'submit complaint when score below threshold' do
      command_bus = FakeCommandBus.new
      process = RankingProcess.new
      evaluation_id = SecureRandom.uuid
      recruiter_id = SecureRandom.uuid
      candidate_id = SecureRandom.uuid
      evaluation_note = "Evaluation note: #{SecureRandom.alphanumeric(100)}"

      process.perform(
        YAML.dump(Ranking::RecruiterWasEvaluated.new(
          data: {
            evaluation_id: evaluation_id,
            recruiter_id: recruiter_id,
            candidate_id: candidate_id,
            evaluation_note: evaluation_note
          }
        )), command_bus
      )

      process.perform(
        YAML.dump(Ranking::RankReceived.new(
          data: {
            evaluation_id: evaluation_id,
            score: 49
          }
        )), command_bus
      )

      command = command_bus.received
      assert_not_nil(command.complaint_id)
      assert_equal(command.recruiter_id, recruiter_id)
      assert_equal(command.candidate_id, candidate_id)
      assert_equal(command.note, evaluation_note)
    end

    test 'do not submit complaint when score is fine' do
      command_bus = FakeCommandBus.new
      process = RankingProcess.new
      evaluation_id = SecureRandom.uuid

      process.perform(
        YAML.dump(Ranking::RecruiterWasEvaluated.new(
          data: {
            evaluation_id: evaluation_id,
            recruiter_id: SecureRandom.uuid,
            candidate_id: SecureRandom.uuid,
            evaluation_note: "Evaluation note: #{SecureRandom.alphanumeric(100)}"
          }
        )), command_bus
      )

      process.perform(
        YAML.dump(Ranking::RankReceived.new(
          data: {
            evaluation_id: evaluation_id,
            score: 50
          }
        )), command_bus
      )

      command = command_bus.received
      assert_instance_of(Ranking::RequestRankCalculation, command)
      assert_equal(command.evaluation_id, evaluation_id)
    end
  end
end
