# Komplex: Multi-Vendor Marketplace Extension for SpreeCommerce
#
# This is the main module file for the Komplex extension.
# It requires the engine and other dependencies.

require 'spree/komplex_configuration'
require 'komplex/engine'

module Komplex
  # Configuration
  class << self
    def configuration
      @configuration ||= Spree::KomplexConfiguration.new
    end

    def configuration=(config)
      @configuration = config
    end

    def configure
      yield configuration
    end
  end
end
