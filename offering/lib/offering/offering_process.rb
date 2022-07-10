module Offering
  class OfferingProcess < ApplicationJob
    queue_as :default

    class State < ActiveRecord::Base
      self.table_name = "offering_process_states"
      serialize :data

      def self.get_by_advertisement_id(advertisement_id)
        transaction do
          lock.find_or_create_by(advertisement_id: advertisement_id).tap do |s|
            s.data ||= {
              recruiters_that_made_an_offer: []
            }
            yield s
            s.save!
          end
        end
      end
    end

    def perform(serialized_event, command_bus = Rails.configuration.command_bus)
      event = YAML.load(serialized_event)
      State.get_by_advertisement_id(event.data.fetch(:advertisement_id)) do |state|
        case event
        when Offering::OfferRequested
          recruiters = state.data[:recruiters_that_made_an_offer].clone
          state.data[:recruiters_that_made_an_offer] << event.data.fetch(:recruiter_id)
          command_bus.call(
            MakeAnOffer.new(
              event.data.fetch(:offer_id),
              recruiters
            )
          )
        else
          raise ArgumentError
        end
      end
    end

  end
end
