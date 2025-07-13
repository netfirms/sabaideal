# frozen_string_literal: true

module Komplex
  class Engine < Rails::Engine
    require 'spree/core'

    isolate_namespace Komplex
    engine_name 'komplex'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')).sort.each do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)

    # Register Komplex tab in Spree Admin
    initializer 'komplex.admin_menu' do
      if defined?(Spree::Admin::Config)
        Spree::Admin::Config.configure do |config|
          config.menu_items << config.class::MenuItem.new(
            [:vendors],
            'store',
            label: 'komplex.vendors.title',
            condition: -> { can?(:manage, Komplex::Vendor) }
          )
          config.menu_items << config.class::MenuItem.new(
            [:listings],
            'list',
            label: 'komplex.listings.title',
            condition: -> { can?(:manage, Komplex::Listing) }
          )
          config.menu_items << config.class::MenuItem.new(
            [:promotions],
            'gift',
            label: 'komplex.promotions.title',
            condition: -> { can?(:manage, Komplex::Promotion) }
          )
          config.menu_items << config.class::MenuItem.new(
            [:advertisements],
            'megaphone',
            label: 'komplex.advertisements.title',
            condition: -> { can?(:manage, Komplex::Advertisement) }
          )
        end
      elsif defined?(Rails) && Rails.application
        Rails.application.config.to_prepare do
          Spree::Admin::BaseController.class_eval do
            def self.komplex_menu_items
              [
                { url: :admin_vendors_path, icon: 'store', label: 'komplex.vendors.title', condition: -> { can?(:manage, Komplex::Vendor) } },
                { url: :admin_listings_path, icon: 'list', label: 'komplex.listings.title', condition: -> { can?(:manage, Komplex::Listing) } },
                { url: :admin_promotions_path, icon: 'gift', label: 'komplex.promotions.title', condition: -> { can?(:manage, Komplex::Promotion) } },
                { url: :admin_advertisements_path, icon: 'megaphone', label: 'komplex.advertisements.title', condition: -> { can?(:manage, Komplex::Advertisement) } }
              ]
            end
          end
        end
      end
    end

    # Register Komplex permissions
    initializer 'komplex.register_ability' do
      if defined?(Spree::Ability)
        Spree::Ability.register_ability(Komplex::Ability)
      end
    end

    # Register Komplex webhooks
    initializer 'komplex.register_webhooks' do
      # Skip if Spree::Webhooks is not defined or is disabled
      next unless defined?(Spree::Webhooks) && !Spree::Webhooks.disabled?

      # Skip if register_subscriber method is not available
      next unless Spree::Webhooks.respond_to?(:register_subscriber)

      # Register the subscriber
      Spree::Webhooks.register_subscriber(Komplex::Webhooks::Subscriber)
    end
  end
end
