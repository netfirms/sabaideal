# frozen_string_literal: true

module Spree
  module Event
    module Subscriber
      extend ActiveSupport::Concern

      class_methods do
        def event_action(action)
          event_actions << action
        end

        def event_actions
          @event_actions ||= []
        end
      end
    end
  end
end