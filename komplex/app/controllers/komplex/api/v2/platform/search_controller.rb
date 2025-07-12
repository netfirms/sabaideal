# frozen_string_literal: true

module Komplex
  module Api
    module V2
      module Platform
        class SearchController < ::Spree::Api::V2::Platform::BaseController
          def index
            render_serialized_payload { serialize_search_results(search_results) }
          end

          private

          def search_results
            listings = Komplex::Listing.published
            
            # Apply basic filters
            listings = apply_basic_filters(listings)
            
            # Apply listing type specific filters
            listings = apply_type_specific_filters(listings)
            
            # Apply sorting
            listings = apply_sorting(listings)
            
            # Apply pagination
            listings.page(params[:page] || 1).per(params[:per_page] || 24)
          end

          def apply_basic_filters(listings)
            # Filter by listing type
            listings = listings.by_type(params[:type]) if params[:type].present?
            
            # Filter by vendor
            listings = listings.by_vendor(params[:vendor_id]) if params[:vendor_id].present?
            
            # Filter by featured status
            listings = listings.featured if params[:featured] == 'true'
            
            # Filter by price range
            if params[:min_price].present?
              listings = listings.where('price >= ?', params[:min_price])
            end
            
            if params[:max_price].present?
              listings = listings.where('price <= ?', params[:max_price])
            end
            
            # Filter by keyword search
            if params[:q].present?
              listings = listings.where('title ILIKE ? OR description ILIKE ?', "%#{params[:q]}%", "%#{params[:q]}%")
            end
            
            listings
          end

          def apply_type_specific_filters(listings)
            case params[:type]
            when 'Property'
              apply_property_filters(listings)
            when 'Restaurant'
              apply_restaurant_filters(listings)
            when 'Service'
              apply_service_filters(listings)
            else
              listings
            end
          end

          def apply_property_filters(listings)
            return listings unless params[:type] == 'Property'
            
            # Join with properties table
            listings = listings.joins('INNER JOIN komplex_properties ON komplex_properties.listing_id = komplex_listings.id')
            
            # Filter by property type
            if params[:property_type].present?
              listings = listings.where('komplex_properties.property_type = ?', params[:property_type])
            end
            
            # Filter by listing type (rent/sale)
            if params[:listing_type].present?
              listings = listings.where('komplex_properties.listing_type = ?', params[:listing_type])
            end
            
            # Filter by bedrooms
            if params[:bedrooms].present?
              listings = listings.where('komplex_properties.bedrooms >= ?', params[:bedrooms])
            end
            
            # Filter by bathrooms
            if params[:bathrooms].present?
              listings = listings.where('komplex_properties.bathrooms >= ?', params[:bathrooms])
            end
            
            # Filter by area
            if params[:min_area].present?
              listings = listings.where('komplex_properties.area >= ?', params[:min_area])
            end
            
            if params[:max_area].present?
              listings = listings.where('komplex_properties.area <= ?', params[:max_area])
            end
            
            # Filter by location
            if params[:city].present?
              listings = listings.where('komplex_properties.city ILIKE ?', "%#{params[:city]}%")
            end
            
            # Filter by furnished status
            if params[:furnished].present?
              listings = listings.where('komplex_properties.furnished = ?', params[:furnished] == 'true')
            end
            
            listings
          end

          def apply_restaurant_filters(listings)
            return listings unless params[:type] == 'Restaurant'
            
            # Join with restaurants table
            listings = listings.joins('INNER JOIN komplex_restaurants ON komplex_restaurants.listing_id = komplex_listings.id')
            
            # Filter by cuisine type
            if params[:cuisine_type].present?
              listings = listings.where('komplex_restaurants.cuisine_type = ?', params[:cuisine_type])
            end
            
            # Filter by city
            if params[:city].present?
              listings = listings.where('komplex_restaurants.city ILIKE ?', "%#{params[:city]}%")
            end
            
            # Filter by delivery availability
            if params[:delivery_available].present?
              listings = listings.where('komplex_restaurants.delivery_available = ?', params[:delivery_available] == 'true')
            end
            
            # Filter by takeout availability
            if params[:takeout_available].present?
              listings = listings.where('komplex_restaurants.takeout_available = ?', params[:takeout_available] == 'true')
            end
            
            listings
          end

          def apply_service_filters(listings)
            return listings unless params[:type] == 'Service'
            
            # Join with services table
            listings = listings.joins('INNER JOIN komplex_services ON komplex_services.listing_id = komplex_listings.id')
            
            # Filter by category
            if params[:category_id].present?
              listings = listings.where('komplex_services.category_id = ?', params[:category_id])
            end
            
            # Filter by pricing model
            if params[:pricing_model].present?
              listings = listings.where('komplex_services.pricing_model = ?', params[:pricing_model])
            end
            
            # Filter by remote availability
            if params[:remote_available].present?
              listings = listings.where('komplex_services.remote_available = ?', params[:remote_available] == 'true')
            end
            
            listings
          end

          def apply_sorting(listings)
            case params[:sort]
            when 'newest'
              listings.order(created_at: :desc)
            when 'oldest'
              listings.order(created_at: :asc)
            when 'price_asc'
              listings.order(price: :asc)
            when 'price_desc'
              listings.order(price: :desc)
            else
              listings.order(created_at: :desc)
            end
          end

          def serialize_search_results(results)
            Komplex::Api::V2::Platform::ListingSerializer.new(
              results,
              include: [:vendor, :listable]
            ).serializable_hash
          end
        end
      end
    end
  end
end