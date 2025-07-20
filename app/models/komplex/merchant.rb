module Komplex
  class Merchant < ApplicationRecord
    self.table_name = 'komplex_merchants'

    has_one_attached :logo

    belongs_to :user, class_name: 'Spree::User'
    has_many :listings, class_name: 'Komplex::Listing', dependent: :destroy
    has_many :advertisements, class_name: 'Komplex::Advertisement', dependent: :destroy
    has_many :commissions, class_name: 'Komplex::Commission', dependent: :destroy
    has_many :payouts, class_name: 'Komplex::Payout', dependent: :destroy

    validates :name, presence: true
    validates :status, presence: true, inclusion: { in: %w[pending approved rejected] }
    validates :commission_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

    scope :approved, -> { where(status: 'approved') }
    scope :pending, -> { where(status: 'pending') }
    scope :rejected, -> { where(status: 'rejected') }

    def approved?
      status == 'approved'
    end

    def pending?
      status == 'pending'
    end

    def rejected?
      status == 'rejected'
    end

    def approve!
      update(status: 'approved')
    end

    def reject!
      update(status: 'rejected')
    end

    def can_be_deleted?
      true
    end
  end
end
