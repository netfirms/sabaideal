# frozen_string_literal: true

module Komplex
  class Payout < ApplicationRecord
    belongs_to :vendor

    validates :amount, presence: true, numericality: { greater_than: 0 }

    scope :pending, -> { where(status: 'pending') }
    scope :processing, -> { where(status: 'processing') }
    scope :completed, -> { where(status: 'completed') }
    scope :failed, -> { where(status: 'failed') }
    scope :by_vendor, ->(vendor_id) { where(vendor_id: vendor_id) }
    scope :by_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }

    enum status: {
      pending: 'pending',
      processing: 'processing',
      completed: 'completed',
      failed: 'failed'
    }

    def process!
      return false unless pending?

      update(status: :processing)
      PayoutProcessingWorker.perform_async(id)
      true
    end

    def mark_as_completed!(transaction_id)
      update(
        status: :completed,
        transaction_id: transaction_id,
        processed_at: Time.current
      )
    end

    def mark_as_failed!(reason = nil)
      update(
        status: :failed,
        notes: reason.present? ? "Failed: #{reason}" : "Failed without specific reason",
        processed_at: Time.current
      )
    end

    def pending?
      status == 'pending'
    end

    def processing?
      status == 'processing'
    end

    def completed?
      status == 'completed'
    end

    def failed?
      status == 'failed'
    end

    def self.create_for_vendor(vendor, options = {})
      commissions = vendor.commissions.pending
      return nil if commissions.empty?

      amount = options[:amount] || commissions.sum(:vendor_amount)
      return nil if amount <= 0

      transaction do
        payout = create!(
          vendor: vendor,
          amount: amount,
          notes: options[:notes]
        )

        commissions.update_all(status: :paid, paid_at: Time.current) if payout.persisted?
        payout
      end
    end
  end
end