require 'rails_helper'

RSpec.describe Komplex::RealEstateProperty, type: :model do
  describe 'validations' do
    it 'validates presence of property_type' do
      property = Komplex::RealEstateProperty.new
      property.valid?
      expect(property.errors[:property_type]).to include("can't be blank")
    end

    it 'validates uniqueness of address with same property details' do
      # Create a property
      property1 = Komplex::RealEstateProperty.create(
        property_type: 'apartment',
        listing_type: 'rent',
        bedrooms: 2,
        bathrooms: 1,
        area: 100,
        area_unit: 'sqm',
        address: '123 Test St'
      )

      # Try to create another property with the same details
      property2 = Komplex::RealEstateProperty.new(
        property_type: 'apartment',
        listing_type: 'rent',
        bedrooms: 2,
        bathrooms: 1,
        area: 100,
        area_unit: 'sqm',
        address: '123 Test St'
      )

      property2.valid?
      expect(property2.errors[:address]).to include('already exists for a property with the same details')
    end

    it 'allows properties with different details' do
      # Create a property
      property1 = Komplex::RealEstateProperty.create(
        property_type: 'apartment',
        listing_type: 'rent',
        bedrooms: 2,
        bathrooms: 1,
        area: 100,
        area_unit: 'sqm',
        address: '123 Test St'
      )

      # Create another property with different details
      property2 = Komplex::RealEstateProperty.new(
        property_type: 'house',  # Different property_type
        listing_type: 'rent',
        bedrooms: 2,
        bathrooms: 1,
        area: 100,
        area_unit: 'sqm',
        address: '123 Test St'
      )

      expect(property2).to be_valid
    end
  end
end