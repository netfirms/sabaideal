# frozen_string_literal: true

module Komplex
  class Advertisement < ApplicationRecord
    belongs_to :vendor
    belongs_to :listing, optional: true

    has_one_attached :image

    validates :title, :placement, :ad_type, :starts_at, :ends_at, :cost, presence: true
    validates :cost, numericality: { greater_than: 0 }
    validate :end_date_after_start_date
    validate :vendor_allowed_to_advertise
    validate :listing_belongs_to_vendor

    scope :active, -> { where(status: 'active').where('starts_at <= ? AND ends_at >= ?', Time.current, Time.current) }
    scope :pending, -> { where(status: 'pending') }
    scope :completed, -> { where(status: 'completed') }
    scope :rejected, -> { where(status: 'rejected') }
    scope :by_placement, ->(placement) { where(placement: placement) }
    scope :by_ad_type, ->(ad_type) { where(ad_type: ad_type) }
    scope :by_vendor, ->(vendor_id) { where(vendor_id: vendor_id) }
    scope :current_and_upcoming, -> { where('ends_at >= ?', Time.current) }

    enum status: {
      pending: 'pending',
      active: 'active',
      completed: 'completed',
      rejected: 'rejected'
    }

    def active?
      status == 'active' && starts_at <= Time.current && ends_at >= Time.current
    end

    def expired?
      ends_at < Time.current
    end

    def upcoming?
      starts_at > Time.current
    end

    def approve!
      update(status: :active)
    end

    def reject!(reason = nil)
      update(status: :rejected, rejection_reason: reason)
    end

    def complete!
      update(status: :completed)
    end

    def duration_in_days
      ((ends_at - starts_at) / 1.day).to_i
    end

    private

    def end_date_after_start_date
      return if ends_at.blank? || starts_at.blank?

      if ends_at < starts_at
        errors.add(:ends_at, "must be after the start date")
      end
    end

    def vendor_allowed_to_advertise
      if !Komplex.configuration.allow_vendor_advertisements
        errors.add(:base, "vendor advertisements are not allowed")
      end
    end

    def listing_belongs_to_vendor
      if listing.present? && listing.vendor_id != vendor_id
        errors.add(:listing_id, "must belong to the vendor")
      end
    end
  end
end