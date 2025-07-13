# frozen_string_literal: true

require 'spree_core'
require 'spree_api'
require 'spree_admin'
require 'spree_extension'

require 'komplex/engine'
require 'komplex/version'
require 'komplex/webhooks'
require_relative '../app/helpers/komplex/form_helper'

# Rails will automatically discover generators in the lib/generators directory,
# so we don't need to explicitly require them

module Komplex
  # Configuration class for Komplex
  class Configuration
    attr_accessor :vendor_approval_required, 
                  :listing_approval_required,
                  :default_commission_rate,
                  :allow_vendor_promotions,
                  :allow_vendor_advertisements,
                  :admin_products_per_page

    def initialize
      @vendor_approval_required = true
      @listing_approval_required = true
      @default_commission_rate = 0.10 # 10%
      @allow_vendor_promotions = true
      @allow_vendor_advertisements = true
      @admin_products_per_page = 15
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
