# frozen_string_literal: true

module Komplex
  module ListingDecorator
    def to_spree_product
      product = Spree::Product.find_or_initialize_by(name: title)
      product.description = description
      product.price = price
      product.shipping_category = Spree::ShippingCategory.find_or_create_by(name: 'Default')
      product.available_on = published_at
      product.stores = [vendor.store].compact

      # Set product properties based on listing type
      case listable_type
      when 'Komplex::Property'
        setup_property_product_properties(product)
      when 'Komplex::Restaurant'
        setup_restaurant_product_properties(product)
      when 'Komplex::Service'
        setup_service_product_properties(product)
      end

      # Set vendor_id for commission calculation
      product.vendor_id = vendor.id if product.respond_to?(:vendor_id=)

      # Save the product
      product.save
      
      # Copy images
      copy_images_to_product(product)
      
      product
    end

    def update_spree_product
      product = Spree::Product.find_by(name: title)
      return to_spree_product unless product

      product.description = description
      product.price = price
      product.available_on = published_at
      
      # Update product properties
      case listable_type
      when 'Komplex::Property'
        setup_property_product_properties(product)
      when 'Komplex::Restaurant'
        setup_restaurant_product_properties(product)
      when 'Komplex::Service'
        setup_service_product_properties(product)
      end

      product.save
      product
    end

    def update_average_rating
      avg = reviews.approved.average(:rating) || 0
      update_column(:average_rating, avg)
      
      # Update Spree product rating if it exists
      product = Spree::Product.find_by(name: title)
      product.update_column(:avg_rating, avg) if product && product.respond_to?(:avg_rating)
    end

    private

    def setup_property_product_properties(product)
      property = listable
      add_product_property(product, 'property_type', property.property_type)
      add_product_property(product, 'listing_type', property.listing_type)
      add_product_property(product, 'bedrooms', property.bedrooms.to_s)
      add_product_property(product, 'bathrooms', property.bathrooms.to_s)
      add_product_property(product, 'area', "#{property.area} #{property.area_unit}")
      add_product_property(product, 'address', property.address)
      add_product_property(product, 'city', property.city)
      add_product_property(product, 'country', property.country)
    end

    def setup_restaurant_product_properties(product)
      restaurant = listable
      add_product_property(product, 'cuisine_type', restaurant.cuisine_type)
      add_product_property(product, 'address', restaurant.address)
      add_product_property(product, 'city', restaurant.city)
      add_product_property(product, 'country', restaurant.country)
      add_product_property(product, 'delivery_available', restaurant.delivery_available.to_s)
      add_product_property(product, 'takeout_available', restaurant.takeout_available.to_s)
    end

    def setup_service_product_properties(product)
      service = listable
      add_product_property(product, 'service_category', service.category.name)
      add_product_property(product, 'pricing_model', service.pricing_model)
      add_product_property(product, 'duration', service.formatted_duration) if service.duration_minutes
      add_product_property(product, 'remote_available', service.remote_available.to_s)
    end

    def add_product_property(product, property_name, property_value)
      return if property_value.blank?
      
      property = Spree::Property.find_or_create_by(name: property_name, presentation: property_name.titleize)
      product_property = product.product_properties.find_or_initialize_by(property: property)
      product_property.value = property_value
      product_property.save
    end

    def copy_images_to_product(product)
      return unless product.images.empty?
      
      if main_image.attached?
        product.images.create(attachment: main_image.blob)
      end
      
      additional_images.each do |image|
        product.images.create(attachment: image.blob)
      end
    end
  end
end

Komplex::Listing.prepend Komplex::ListingDecorator if defined?(Komplex::Listing)