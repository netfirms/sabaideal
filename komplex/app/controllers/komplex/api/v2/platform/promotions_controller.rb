# frozen_string_literal: true

module Komplex
  module Api
    module V2
      module Platform
        class PromotionsController < ::Spree::Api::V2::Platform::ResourceController
          private

          def model_class
            Komplex::Promotion
          end

          def resource_serializer
            Komplex::Api::V2::Platform::PromotionSerializer
          end

          def collection_serializer
            Komplex::Api::V2::Platform::PromotionSerializer
          end

          def resource_finder
            Komplex::Promotion.find(params[:id])
          end

          def collection_finder
            promotions = Komplex::Promotion.all
            
            # Apply filters
            promotions = promotions.by_vendor(params[:vendor_id]) if params[:vendor_id].present?
            promotions = promotions.by_listing(params[:listing_id]) if params[:listing_id].present?
            promotions = promotions.platform_wide if params[:platform_wide] == 'true'
            
            # Apply date filters
            if params[:active] == 'true'
              promotions = promotions.active
            elsif params[:expired] == 'true'
              promotions = promotions.expired
            elsif params[:upcoming] == 'true'
              promotions = promotions.upcoming
            end
            
            # Apply code filter
            promotions = promotions.with_code(params[:code]) if params[:code].present?
            
            promotions
          end

          def spree_permitted_attributes
            [
              :title, :description, :promotion_type, :discount_amount,
              :starts_at, :ends_at, :vendor_id, :listing_id, :code,
              :usage_limit, :usage_count
            ]
          end

          def collection_actions
            [:index, :create]
          end

          def member_actions
            [:show, :update, :destroy]
          end
        end
      end
    end
  end
end