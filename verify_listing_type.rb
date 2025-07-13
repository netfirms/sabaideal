#!/usr/bin/env ruby
# This script verifies that the `type` method works correctly on Komplex::Listing instances

require_relative './config/environment'

# Create a test vendor
vendor = Komplex::Vendor.first_or_create!(name: 'Test Vendor')

# Create a test property
property = Komplex::Property.create!(
  title: 'Test Property',
  description: 'A test property'
)

# Create a listing for the property
listing = Komplex::Listing.create!(
  title: 'Test Listing',
  vendor: vendor,
  listable: property
)

# Verify that the type method returns the expected value
puts "Listing type: #{listing.type}"
puts "Expected type: Property"
puts "Test passed: #{listing.type == 'Property'}"

# Clean up
listing.destroy
property.destroy