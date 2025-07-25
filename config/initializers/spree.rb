# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# Note: If a preference is set here it will be stored within the cache & database upon initialization.
#       Just removing an entry from this initializer will not make the preference value go away.
#       Instead you must either set a new value or remove entry, clear cache, and remove database entry.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'
#
# More on configuring Spree preferences can be found at:
# https://docs.spreecommerce.org/developer/customization
Spree.config do |config|
  # Example:
  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false
end

# Background job queue names
# Spree.queues.default = :default
# Spree.queues.variants = :default
# Spree.queues.stock_location_stock_items = :default
# Spree.queues.coupon_codes = :default

# Use a CDN host for images, eg. Cloudfront
# This is used in the frontend to generate absolute URLs to images
# Default is nil and your application host will be used
# Spree.cdn_host = 'cdn.example.com'

# Use a different service for storage (S3, google, etc)
# unless Rails.env.test?
#   Spree.private_storage_service_name = :amazon_public # public assets, such as product images
#   Spree.public_storage_service_name = :amazon_private # private assets, such as invoices, etc
# end

# Configure Spree Dependencies
#
# Note: If a dependency is set here it will NOT be stored within the cache & database upon initialization.
#       Just removing an entry from this initializer will make the dependency value go away.
#
# More on how to use Spree dependencies can be found at:
# https://docs.spreecommerce.org/customization/dependencies
Spree.dependencies do |dependencies|
  # Example:
  # Uncomment to change the default Service handling adding Items to Cart
  # dependencies.cart_add_item_service = 'MyNewAwesomeService'
end

# Spree::Api::Dependencies.storefront_cart_serializer = 'MyRailsApp::CartSerializer'

# uncomment lines below to add your own custom business logic
# such as promotions, shipping methods, etc
Rails.application.config.after_initialize do
  # Rails.application.config.spree.shipping_methods << Spree::ShippingMethods::SuperExpensiveNotVeryFastShipping
  # Rails.application.config.spree.payment_methods << Spree::PaymentMethods::VerySafeAndReliablePaymentMethod

  # Rails.application.config.spree.calculators.tax_rates << Spree::TaxRates::FinanceTeamForcedMeToCodeThis

  # Rails.application.config.spree.stock_splitters << Spree::Stock::Splitters::SecretLogicSplitter

  # Rails.application.config.spree.adjusters << Spree::Adjustable::Adjuster::TaxTheRich

  # Custom promotions
  # Rails.application.config.spree.calculators.promotion_actions_create_adjustments << Spree::Calculators::PromotionActions::CreateAdjustments::AddDiscountForFriends
  # Rails.application.config.spree.calculators.promotion_actions_create_item_adjustments << Spree::Calculators::PromotionActions::CreateItemAdjustments::FinanceTeamForcedMeToCodeThis
  # Rails.application.config.spree.promotions.rules << Spree::Promotions::Rules::OnlyForVIPCustomers
  # Rails.application.config.spree.promotions.actions << Spree::Promotions::Actions::GiftWithPurchase

  # Rails.application.config.spree.taxon_rules << Spree::TaxonRules::ProductsWithColor

  # Rails.application.config.spree.exports << Spree::Exports::Payments
  # Rails.application.config.spree.reports << Spree::Reports::MassivelyOvercomplexReportForCfo

  # Themes and page builder
  Rails.application.config.spree.themes << Spree::Themes::KomplexTheme
  # Rails.application.config.spree.theme_layout_sections << Spree::PageSections::SuperImportantCeoBio
  # Rails.application.config.spree.page_sections << Spree::PageSections::ContactFormToGetInTouch
  # Rails.application.config.spree.page_blocks << Spree::PageBlocks::BigRedButtonToCallSales

  # Rails.application.config.spree_storefront.head_partials << 'spree/shared/that_js_snippet_that_marketing_forced_me_to_include'

  # Komplex Marketplace Extension
  # In Spree 5.1, the way to add menu items has changed
  # Custom menu items are now added through a partial at:
  # app/views/spree/admin/shared/sidebar/_custom_nav.html.erb
end

Spree.user_class = 'Spree::User'
# Use a different class for admin users
# Spree.admin_user_class = 'AdminUser'

Spree.google_places_api_key = ENV['GOOGLE_PLACES_API_KEY'] if ENV['GOOGLE_PLACES_API_KEY'].present?
Spree.screenshot_api_token = ENV['SCREENSHOT_API_TOKEN'] if ENV['SCREENSHOT_API_TOKEN'].present?

Rails.application.config.to_prepare do
  require_dependency 'spree/authentication_helpers'
end
