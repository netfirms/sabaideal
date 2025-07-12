# frozen_string_literal: true

module Komplex
  class CommissionProcessingWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'komplex_commissions', retry: 3

    def perform(order_id)
      order = Spree::Order.find(order_id)
      return unless order.completed?

      order.line_items.each do |line_item|
        process_line_item(line_item, order)
      end
    end

    private

    def process_line_item(line_item, order)
      # Skip if not a Komplex product
      return unless line_item_belongs_to_vendor?(line_item)

      vendor = find_vendor_for_line_item(line_item)
      return unless vendor

      # Calculate commission
      item_total = line_item.amount
      commission_rate = vendor.commission_rate
      commission_amount = (item_total * commission_rate).round(2)
      vendor_amount = item_total - commission_amount

      # Create commission record
      create_commission(vendor, order, line_item, vendor_amount, commission_amount)
    end

    def line_item_belongs_to_vendor?(line_item)
      return false unless line_item.product.respond_to?(:vendor_id)
      
      line_item.product.vendor_id.present?
    end

    def find_vendor_for_line_item(line_item)
      vendor_id = line_item.product.vendor_id
      Komplex::Vendor.find_by(id: vendor_id)
    end

    def create_commission(vendor, order, line_item, vendor_amount, commission_amount)
      Komplex::Commission.create!(
        vendor: vendor,
        order: order,
        line_item: line_item,
        vendor_amount: vendor_amount,
        commission_amount: commission_amount
      )
    rescue => e
      Rails.logger.error("Failed to create commission for order #{order.number}, line item #{line_item.id}: #{e.message}")
      Sentry.capture_exception(e) if defined?(Sentry)
    end
  end
end