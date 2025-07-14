module Spree
  module Admin
    module BaseControllerDecorator
      def komplex_menu_items
        original_items = super
        
        # Add example menu item
        example_item = { 
          url: :admin_root_path, 
          icon: 'lightbulb', 
          label: 'komplex.example.title', 
          condition: -> { can?(:admin, Spree::Store) } 
        }
        
        # Insert the example item at the beginning of the array
        original_items.unshift(example_item)
      end
    end
  end
end

Spree::Admin::BaseController.prepend Spree::Admin::BaseControllerDecorator if defined?(Spree::Admin::BaseController)