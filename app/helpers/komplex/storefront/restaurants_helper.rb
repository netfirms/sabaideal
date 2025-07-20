module Komplex
  module Storefront
    module RestaurantsHelper
      def current_merchant
        @current_merchant ||= spree_current_user&.merchant
      end
    end
  end
end