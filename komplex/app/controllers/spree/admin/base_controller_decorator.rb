# frozen_string_literal: true

module Spree
  module Admin
    module BaseControllerDecorator
      def self.prepended(base)
        base.helper_method :komplex_menu_items
      end

      def komplex_menu_items
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

Spree::Admin::BaseController.prepend Spree::Admin::BaseControllerDecorator if defined?(Spree::Admin::BaseController)