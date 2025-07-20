module Komplex
  class Advertisement < ApplicationRecord
    self.table_name = 'komplex_advertisements'

    belongs_to :merchant, class_name: 'Komplex::Merchant'
    has_one :listing, class_name: 'Komplex::Listing', as: :listable, dependent: :destroy
    accepts_nested_attributes_for :listing

    validates :title, presence: true
    validates :description, presence: true
    validates :placement, presence: true
    validates :ad_type, presence: true
    validates :starts_at, presence: true
    validates :ends_at, presence: true
    validates :cost, numericality: { greater_than_or_equal_to: 0 }
    validates :status, presence: true, inclusion: { in: %w[pending active inactive] }

    scope :active, -> { where(status: 'active') }
    scope :pending, -> { where(status: 'pending') }
    scope :inactive, -> { where(status: 'inactive') }

    def active?
      status == 'active'
    end

    def pending?
      status == 'pending'
    end

    def inactive?
      status == 'inactive'
    end

    def activate!
      update(status: 'active')
    end

    def deactivate!
      update(status: 'inactive')
    end
  end
end
