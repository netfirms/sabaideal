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
      Spree::Backend::Config.configure do |config|
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
    end

    # Register Komplex permissions
    initializer 'komplex.register_ability' do
      Spree::Ability.register_ability(Komplex::Ability)
    end

    # Register Komplex webhooks
    initializer 'komplex.register_webhooks' do
      next unless defined?(Spree::Webhooks) && Spree::Webhooks.enabled?

      Spree::Webhooks.register_subscriber(Komplex::Webhooks::Subscriber)
    end
  end
end