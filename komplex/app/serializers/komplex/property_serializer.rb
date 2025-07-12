# frozen_string_literal: true

module Komplex
  class PropertySerializer < Spree::BaseSerializer
    set_type :property

    attributes :property_type, :listing_type, :bedrooms, :bathrooms, :area, :area_unit,
               :address, :city, :state, :postal_code, :country, :latitude, :longitude,
               :furnished, :available_from, :created_at, :updated_at

    attribute :full_address do |property|
      [
        property.address,
        property.city,
        property.state,
        property.postal_code,
        property.country
      ].compact.join(', ')
    end

    attribute :has_coordinates do |property|
      property.latitude.present? && property.longitude.present?
    end

    belongs_to :listing, serializer: :listing
  end
end