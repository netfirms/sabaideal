# frozen_string_literal: true

module Komplex
  module Api
    module V2
      module Platform
        class VendorsController < ::Spree::Api::V2::Platform::ResourceController
          private

          def model_class
            Komplex::Vendor
          end

          def resource_serializer
            Komplex::Api::V2::Platform::VendorSerializer
          end

          def collection_serializer
            Komplex::Api::V2::Platform::VendorSerializer
          end

          def resource_finder
            Komplex::Vendor.find(params[:id])
          end

          def collection_finder
            Komplex::Vendor.all
          end

          def spree_permitted_attributes
            [
              :name, :description, :status, :commission_rate,
              :user_id, settings: {}
            ]
          end

          def collection_actions
            [:index, :create]
          end

          def member_actions
            [:show, :update, :destroy, :approve, :reject]
          end

          def approve
            vendor = resource_finder
            
            if vendor.approve!
              render_serialized_payload { serialize_resource(vendor) }
            else
              render_error_payload(vendor.errors)
            end
          end

          def reject
            vendor = resource_finder
            
            if vendor.reject!
              render_serialized_payload { serialize_resource(vendor) }
            else
              render_error_payload(vendor.errors)
            end
          end
        end
      end
    end
  end
end