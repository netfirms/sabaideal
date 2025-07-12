# frozen_string_literal: true

module Komplex
  module Api
    module V2
      module Platform
        class PayoutsController < ::Spree::Api::V2::Platform::ResourceController
          private

          def model_class
            Komplex::Payout
          end

          def resource_serializer
            Komplex::Api::V2::Platform::PayoutSerializer
          end

          def collection_serializer
            Komplex::Api::V2::Platform::PayoutSerializer
          end

          def resource_finder
            Komplex::Payout.find(params[:id])
          end

          def collection_finder
            payouts = Komplex::Payout.all
            
            # Apply filters
            payouts = payouts.by_vendor(params[:vendor_id]) if params[:vendor_id].present?
            payouts = payouts.where(status: params[:status]) if params[:status].present?
            
            # Apply date filters
            if params[:start_date].present? && params[:end_date].present?
              start_date = Date.parse(params[:start_date])
              end_date = Date.parse(params[:end_date])
              payouts = payouts.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
            end
            
            # Apply sorting
            case params[:sort]
            when 'newest'
              payouts = payouts.order(created_at: :desc)
            when 'oldest'
              payouts = payouts.order(created_at: :asc)
            when 'amount_high'
              payouts = payouts.order(amount: :desc)
            when 'amount_low'
              payouts = payouts.order(amount: :asc)
            else
              payouts = payouts.order(created_at: :desc)
            end
            
            payouts
          end

          def spree_permitted_attributes
            [
              :vendor_id, :amount, :status, :transaction_id, :notes, :processed_at
            ]
          end

          def collection_actions
            [:index, :create]
          end

          def member_actions
            [:show, :update, :destroy, :process_payout, :mark_as_completed, :mark_as_failed]
          end

          def process_payout
            payout = resource_finder
            
            if payout.process!
              render_serialized_payload { serialize_resource(payout) }
            else
              render_error_payload(payout.errors)
            end
          end

          def mark_as_completed
            payout = resource_finder
            transaction_id = params[:transaction_id] || "manual-#{SecureRandom.hex(6)}"
            
            if payout.mark_as_completed!(transaction_id)
              render_serialized_payload { serialize_resource(payout) }
            else
              render_error_payload(payout.errors)
            end
          end

          def mark_as_failed
            payout = resource_finder
            failure_reason = params[:failure_reason]
            
            if payout.mark_as_failed!(failure_reason)
              render_serialized_payload { serialize_resource(payout) }
            else
              render_error_payload(payout.errors)
            end
          end
        end
      end
    end
  end
end