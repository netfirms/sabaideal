module Komplex
  class RealEstateProperty < ApplicationRecord
    self.table_name = 'komplex_properties'

    belongs_to :property, class_name: 'Spree::Property', optional: true
    has_one :listing, class_name: 'Komplex::Listing', as: :listable, dependent: :destroy
    accepts_nested_attributes_for :listing

    validates :property_type, presence: true
    validates :address, uniqueness: { scope: [:property_type, :listing_type, :bedrooms, :bathrooms, :area, :area_unit], 
                                     message: "already exists for a property with the same details" }
  end
end
