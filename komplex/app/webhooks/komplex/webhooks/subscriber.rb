# frozen_string_literal: true

module Komplex
  module Webhooks
    class Subscriber
      include Spree::Event::Subscriber

      # Order events
      event_action :order_finalized
      event_action :order_canceled

      # User events
      event_action :user_created
      event_action :user_updated

      # Product events
      event_action :product_created
      event_action :product_updated

      # Store events
      event_action :store_created
      event_action :store_updated

      def order_finalized(event)
        order = event.payload[:order]
        return unless order

        # Process commissions for the order
        Komplex::CommissionProcessingWorker.perform_async(order.id)
      end

      def order_canceled(event)
        order = event.payload[:order]
        return unless order

        # Handle commission cancellations if needed
        handle_commission_cancellation(order)
      end

      def user_created(event)
        user = event.payload[:user]
        return unless user

        # Any actions needed when a user is created
        # For example, send welcome email with vendor registration info
        Rails.logger.info("User created: #{user.id}")
      end

      def user_updated(event)
        user = event.payload[:user]
        return unless user

        # Any actions needed when a user is updated
        Rails.logger.info("User updated: #{user.id}")
      end

      def product_created(event)
        product = event.payload[:product]
        return unless product

        # Any actions needed when a product is created
        Rails.logger.info("Product created: #{product.id}")
      end

      def product_updated(event)
        product = event.payload[:product]
        return unless product

        # Any actions needed when a product is updated
        Rails.logger.info("Product updated: #{product.id}")
      end

      def store_created(event)
        store = event.payload[:store]
        return unless store

        # Any actions needed when a store is created
        Rails.logger.info("Store created: #{store.id}")
      end

      def store_updated(event)
        store = event.payload[:store]
        return unless store

        # Any actions needed when a store is updated
        Rails.logger.info("Store updated: #{store.id}")
      end

      private

      def handle_commission_cancellation(order)
        # Find commissions for this order
        commissions = Komplex::Commission.where(order_id: order.id, status: 'pending')
        
        # Mark commissions as failed
        commissions.each do |commission|
          commission.mark_as_failed!("Order #{order.number} was canceled")
        end
      end
    end
  end
end