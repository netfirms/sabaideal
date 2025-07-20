# Configure Komplex Marketplace Extension
#
# This initializer loads the Komplex extension and sets up any necessary configuration.

# Require the Komplex module
require 'komplex'

# Configure Komplex preferences
Komplex.configure do |config|
  # Example:
  # Uncomment to change the default commission rate
  # config.default_commission_rate = 0.15
end

# Add Komplex-specific functionality to Spree
Rails.application.config.after_initialize do
  # Add Komplex to the Spree admin menu
  # This is handled by the custom nav partial in:
  # app/views/spree/admin/shared/sidebar/_custom_nav.html.erb
end

# Ensure Komplex models and controllers are loaded
Rails.application.config.to_prepare do
  # Load Spree::Admin::Komplex module
  require_dependency Rails.root.join('app', 'models', 'spree', 'admin', 'komplex.rb')

  Dir.glob(Rails.root.join('app', 'models', 'komplex', '*.rb')).each do |model|
    require_dependency model
  end

  Dir.glob(Rails.root.join('app', 'controllers', 'komplex', '**', '*.rb')).each do |controller|
    require_dependency controller
  end
end
