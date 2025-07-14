# frozen_string_literal: true

# This initializer adds the Komplex menu to the Spree admin sidebar
# It uses the Spree Admin API to add menu items

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
end
