# frozen_string_literal: true

module Spree
  module StoreDecorator
    def self.prepended(base)
      base.belongs_to :vendor, class_name: 'Komplex::Vendor', optional: true
    end
  end
end

Spree::Store.prepend Spree::StoreDecorator if defined?(Spree::Store)