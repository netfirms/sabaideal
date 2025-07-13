# frozen_string_literal: true

# Configure Komplex settings
Komplex.configure do |config|
  # Whether vendor approval is required before they can list items
  config.vendor_approval_required = true
  
  # Whether listing approval is required before they are published
  config.listing_approval_required = true
  
  # Default commission rate (as a decimal, e.g., 0.10 for 10%)
  config.default_commission_rate = 0.10
  
  # Whether vendors are allowed to create promotions
  config.allow_vendor_promotions = true
  
  # Whether vendors are allowed to purchase advertisements
  config.allow_vendor_advertisements = true

  # Set the number of items to display per page in admin listings
  config.admin_products_per_page = 15
end