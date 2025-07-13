# frozen_string_literal: true

module Komplex
  class Vendor < ApplicationRecord
    belongs_to :user, class_name: 'Spree::User'
    has_many :listings, dependent: :destroy
    has_many :promotions, dependent: :destroy
    has_many :advertisements, dependent: :destroy
    has_many :commissions, dependent: :nullify
    has_many :payouts, dependent: :nullify
    has_many :conversations, dependent: :destroy

    validates :name, presence: true, uniqueness: true
    validates :commission_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

    enum :status, {
      pending: 'pending',
      approved: 'approved',
      rejected: 'rejected'
    }

    scope :active, -> { approved }

    after_create :set_default_commission_rate

    def approve!
      update(status: :approved)
      VendorMailer.approval_notification(self).deliver_later
    end

    def reject!
      update(status: :rejected)
      VendorMailer.rejection_notification(self).deliver_later
    end

    def active?
      approved?
    end

    def pending_listings
      listings.where(status: :pending)
    end

    def published_listings
      listings.where(status: :published)
    end

    def total_sales
      commissions.sum(:vendor_amount)
    end

    def total_commission_paid
      commissions.sum(:commission_amount)
    end

    def pending_payout_amount
      commissions.where(status: :pending).sum(:vendor_amount)
    end

    private

    def set_default_commission_rate
      update(commission_rate: Komplex.configuration.default_commission_rate) if commission_rate.zero?
    end
  end
end
