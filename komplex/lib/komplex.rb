# frozen_string_literal: true

require 'spree_core'
require 'spree_api'
require 'spree_backend'
require 'spree_extension'

require 'komplex/engine'
require 'komplex/version'

module Komplex
  # Configuration class for Komplex
  class Configuration
    attr_accessor :vendor_approval_required, 
                  :listing_approval_required,
                  :default_commission_rate,
                  :allow_vendor_promotions,
                  :allow_vendor_advertisements

    def initialize
      @vendor_approval_required = true
      @listing_approval_required = true
      @default_commission_rate = 0.10 # 10%
      @allow_vendor_promotions = true
      @allow_vendor_advertisements = true
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end