# frozen_string_literal: true

module Komplex
  module Webhooks
    # This file ensures the Komplex::Webhooks module is defined
    # and requires the subscriber class

    # Only require the subscriber class
    # The spree/event module should be loaded by the main application
    require_relative '../../app/webhooks/komplex/webhooks/subscriber'
  end
end
