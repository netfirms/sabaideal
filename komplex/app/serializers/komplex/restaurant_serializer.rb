# frozen_string_literal: true

module Komplex
  class RestaurantSerializer < Spree::BaseSerializer
    set_type :restaurant

    attributes :cuisine_type, :menu_items, :opening_hours, :address, :city, :state, 
               :postal_code, :country, :latitude, :longitude, :delivery_available, 
               :takeout_available, :reservation_required, :created_at, :updated_at

    attribute :full_address do |restaurant|
      [
        restaurant.address,
        restaurant.city,
        restaurant.state,
        restaurant.postal_code,
        restaurant.country
      ].compact.join(', ')
    end

    attribute :has_coordinates do |restaurant|
      restaurant.latitude.present? && restaurant.longitude.present?
    end

    attribute :is_open do |restaurant|
      # This is a placeholder. In a real implementation, this would check
      # the current time against the opening_hours to determine if the
      # restaurant is currently open.
      true
    end

    belongs_to :listing, serializer: :listing
  end
end