# frozen_string_literal: true

module Komplex
  class Commission < ApplicationRecord
    belongs_to :vendor
    belongs_to :order, class_name: 'Spree::Order'
    belongs_to :line_item, class_name: 'Spree::LineItem', optional: true

    validates :vendor_amount, :commission_amount, presence: true
    validates :vendor_amount, :commission_amount, numericality: { greater_than_or_equal_to: 0 }

    scope :pending, -> { where(status: 'pending') }
    scope :paid, -> { where(status: 'paid') }
    scope :failed, -> { where(status: 'failed') }
    scope :by_vendor, ->(vendor_id) { where(vendor_id: vendor_id) }
    scope :by_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }
    scope :ready_for_payout, -> { pending.where('created_at <= ?', 14.days.ago) }

    enum status: {
      pending: 'pending',
      paid: 'paid',
      failed: 'failed'
    }

    def total_amount
      vendor_amount + commission_amount
    end

    def commission_percentage
      return 0 if total_amount.zero?

      (commission_amount / total_amount * 100).round(2)
    end

    def mark_as_paid!
      update(status: :paid, paid_at: Time.current)
    end

    def mark_as_failed!(reason = nil)
      update(status: :failed, failure_reason: reason)
    end

    def pending?
      status == 'pending'
    end

    def paid?
      status == 'paid'
    end

    def failed?
      status == 'failed'
    end

    def self.calculate_commission(amount, commission_rate)
      commission_amount = (amount * commission_rate).round(2)
      vendor_amount = amount - commission_amount
      
      {
        commission_amount: commission_amount,
        vendor_amount: vendor_amount
      }
    end
  end
end