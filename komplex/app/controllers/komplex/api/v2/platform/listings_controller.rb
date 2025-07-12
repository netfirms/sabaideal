# frozen_string_literal: true

module Komplex
  module Api
    module V2
      module Platform
        class ListingsController < ::Spree::Api::V2::Platform::ResourceController
          private

          def model_class
            Komplex::Listing
          end

          def resource_serializer
            Komplex::Api::V2::Platform::ListingSerializer
          end

          def collection_serializer
            Komplex::Api::V2::Platform::ListingSerializer
          end

          def resource_finder
            Komplex::Listing.find(params[:id])
          end

          def collection_finder
            Komplex::Listing.all
          end

          def spree_permitted_attributes
            [
              :title, :description, :price, :vendor_id, 
              :status, :featured, :published_at,
              property_attributes: [
                :property_type, :listing_type, :bedrooms, :bathrooms,
                :area, :area_unit, :address, :city, :state, :postal_code,
                :country, :latitude, :longitude, :furnished, :available_from
              ],
              restaurant_attributes: [
                :cuisine_type, :address, :city, :state, :postal_code,
                :country, :latitude, :longitude, :delivery_available,
                :takeout_available, :reservation_required, menu_items: [], opening_hours: {}
              ],
              service_attributes: [
                :category_id, :pricing_model, :price, :duration_minutes,
                :service_area, :remote_available
              ]
            ]
          end

          def collection_actions
            [:index, :create]
          end

          def member_actions
            [:show, :update, :destroy, :approve, :reject, :feature, :unfeature]
          end

          def approve
            listing = resource_finder
            
            if listing.approve!
              render_serialized_payload { serialize_resource(listing) }
            else
              render_error_payload(listing.errors)
            end
          end

          def reject
            listing = resource_finder
            rejection_reason = params[:rejection_reason]
            
            if listing.reject!(rejection_reason)
              render_serialized_payload { serialize_resource(listing) }
            else
              render_error_payload(listing.errors)
            end
          end

          def feature
            listing = resource_finder
            
            if listing.update(featured: true)
              render_serialized_payload { serialize_resource(listing) }
            else
              render_error_payload(listing.errors)
            end
          end

          def unfeature
            listing = resource_finder
            
            if listing.update(featured: false)
              render_serialized_payload { serialize_resource(listing) }
            else
              render_error_payload(listing.errors)
            end
          end
        end
      end
    end
  end
end