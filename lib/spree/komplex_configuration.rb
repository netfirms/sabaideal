module Spree
  class KomplexConfiguration < Preferences::Configuration
    # Preferences for the Komplex extension
    preference :enabled, :boolean, default: true
    preference :default_commission_rate, :decimal, default: 0.10
    preference :require_merchant_approval, :boolean, default: true
    preference :require_listing_approval, :boolean, default: true
  end
end