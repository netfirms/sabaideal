# frozen_string_literal: true

module Komplex
  module Api
    module V2
      module Platform
        class ReviewsController < ::Spree::Api::V2::Platform::ResourceController
          private

          def model_class
            Komplex::Review
          end

          def resource_serializer
            Komplex::Api::V2::Platform::ReviewSerializer
          end

          def collection_serializer
            Komplex::Api::V2::Platform::ReviewSerializer
          end

          def resource_finder
            Komplex::Review.find(params[:id])
          end

          def collection_finder
            reviews = Komplex::Review.all
            
            # Apply filters
            reviews = reviews.by_listing(params[:listing_id]) if params[:listing_id].present?
            reviews = reviews.by_user(params[:user_id]) if params[:user_id].present?
            reviews = reviews.where(approved: params[:approved]) if params[:approved].present?
            reviews = reviews.where('rating >= ?', params[:min_rating]) if params[:min_rating].present?
            reviews = reviews.where('rating <= ?', params[:max_rating]) if params[:max_rating].present?
            
            # Apply sorting
            case params[:sort]
            when 'newest'
              reviews = reviews.order(created_at: :desc)
            when 'oldest'
              reviews = reviews.order(created_at: :asc)
            when 'highest_rated'
              reviews = reviews.highest_rated
            when 'lowest_rated'
              reviews = reviews.lowest_rated
            else
              reviews = reviews.order(created_at: :desc)
            end
            
            reviews
          end

          def spree_permitted_attributes
            [
              :listing_id, :user_id, :rating, :comment, :approved
            ]
          end

          def collection_actions
            [:index, :create]
          end

          def member_actions
            [:show, :update, :destroy, :approve, :reject]
          end

          def approve
            review = resource_finder
            
            if review.approve!
              render_serialized_payload { serialize_resource(review) }
            else
              render_error_payload(review.errors)
            end
          end

          def reject
            review = resource_finder
            
            if review.reject!
              render_serialized_payload { serialize_resource(review) }
            else
              render_error_payload(review.errors)
            end
          end
        end
      end
    end
  end
end