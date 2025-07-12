# frozen_string_literal: true

module Komplex
  class Property < ApplicationRecord
    has_one :listing, as: :listable, dependent: :destroy

    validates :property_type, :listing_type, :address, :city, :country, presence: true
    validates :bedrooms, :bathrooms, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :area, numericality: { greater_than: 0, allow_nil: true }
    validates :area_unit, inclusion: { in: %w[sqm sqft] }

    before_validation :set_default_area_unit

    scope :for_rent, -> { where(listing_type: 'rent') }
    scope :for_sale, -> { where(listing_type: 'sale') }
    scope :by_property_type, ->(type) { where(property_type: type) }
    scope :by_bedrooms, ->(min) { where('bedrooms >= ?', min) }
    scope :by_bathrooms, ->(min) { where('bathrooms >= ?', min) }
    scope :by_area, ->(min, max = nil) {
      if max.present?
        where('area >= ? AND area <= ?', min, max)
      else
        where('area >= ?', min)
      end
    }
    scope :by_city, ->(city) { where('city ILIKE ?', "%#{city}%") }
    scope :furnished, -> { where(furnished: true) }
    scope :available_from, ->(date) { where('available_from <= ?', date) }

    def full_address
      [address, city, state, postal_code, country].compact.join(', ')
    end

    def for_rent?
      listing_type == 'rent'
    end

    def for_sale?
      listing_type == 'sale'
    end

    private

    def set_default_area_unit
      self.area_unit ||= 'sqm'
    end
  end
end