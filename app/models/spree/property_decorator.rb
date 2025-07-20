module Spree
  module PropertyDecorator
    def self.prepended(base)
      base.has_many :real_estate_properties, class_name: 'Komplex::RealEstateProperty', foreign_key: 'property_id'
    end
  end
end

Spree::Property.prepend Spree::PropertyDecorator