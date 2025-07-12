# frozen_string_literal: true

module Komplex
  module Api
    module V2
      module Platform
        class AdvertisementsController < ::Spree::Api::V2::Platform::ResourceController
          private

          def model_class
            Komplex::Advertisement
          end

          def resource_serializer
            Komplex::Api::V2::Platform::AdvertisementSerializer
          end

          def collection_serializer
            Komplex::Api::V2::Platform::AdvertisementSerializer
          end

          def resource_finder
            Komplex::Advertisement.find(params[:id])
          end

          def collection_finder
            advertisements = Komplex::Advertisement.all
            
            # Apply filters
            advertisements = advertisements.by_vendor(params[:vendor_id]) if params[:vendor_id].present?
            advertisements = advertisements.by_placement(params[:placement]) if params[:placement].present?
            advertisements = advertisements.by_ad_type(params[:ad_type]) if params[:ad_type].present?
            advertisements = advertisements.where(status: params[:status]) if params[:status].present?
            
            # Apply date filters
            if params[:current] == 'true'
              advertisements = advertisements.active
            elsif params[:expired] == 'true'
              advertisements = advertisements.where('ends_at < ?', Time.current)
            elsif params[:upcoming] == 'true'
              advertisements = advertisements.where('starts_at > ?', Time.current)
            end
            
            advertisements
          end

          def spree_permitted_attributes
            [
              :title, :description, :placement, :ad_type,
              :vendor_id, :listing_id, :starts_at, :ends_at,
              :cost, :status
            ]
          end

          def collection_actions
            [:index, :create]
          end

          def member_actions
            [:show, :update, :destroy, :approve, :reject]
          end

          def approve
            advertisement = resource_finder
            
            if advertisement.approve!
              render_serialized_payload { serialize_resource(advertisement) }
            else
              render_error_payload(advertisement.errors)
            end
          end

          def reject
            advertisement = resource_finder
            rejection_reason = params[:rejection_reason]
            
            if advertisement.reject!(rejection_reason)
              render_serialized_payload { serialize_resource(advertisement) }
            else
              render_error_payload(advertisement.errors)
            end
          end
        end
      end
    end
  end
end