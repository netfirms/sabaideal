# frozen_string_literal: true

module Komplex
  class Promotion < ApplicationRecord
    belongs_to :vendor, optional: true
    belongs_to :listing, optional: true

    validates :title, :promotion_type, :discount_amount, :starts_at, :ends_at, presence: true
    validates :discount_amount, numericality: { greater_than: 0 }
    validates :code, uniqueness: true, allow_blank: true
    validates :usage_limit, numericality: { greater_than: 0 }, allow_nil: true
    validate :end_date_after_start_date
    validate :vendor_or_platform_wide

    scope :active, -> { where('starts_at <= ? AND ends_at >= ?', Time.current, Time.current) }
    scope :upcoming, -> { where('starts_at > ?', Time.current) }
    scope :expired, -> { where('ends_at < ?', Time.current) }
    scope :by_vendor, ->(vendor_id) { where(vendor_id: vendor_id) }
    scope :by_listing, ->(listing_id) { where(listing_id: listing_id) }
    scope :platform_wide, -> { where(vendor_id: nil, listing_id: nil) }
    scope :with_code, ->(code) { where('code ILIKE ?', code) }

    def active?
      starts_at <= Time.current && ends_at >= Time.current
    end

    def expired?
      ends_at < Time.current
    end

    def upcoming?
      starts_at > Time.current
    end

    def platform_wide?
      vendor_id.nil? && listing_id.nil?
    end

    def vendor_specific?
      vendor_id.present? && listing_id.nil?
    end

    def listing_specific?
      listing_id.present?
    end

    def usage_limit_reached?
      usage_limit.present? && usage_count >= usage_limit
    end

    def calculate_discount(amount)
      return 0 if amount.nil? || amount <= 0

      if promotion_type == 'percentage'
        (amount * discount_amount / 100).round(2)
      else # fixed_amount
        [discount_amount, amount].min
      end
    end

    def increment_usage!
      increment!(:usage_count)
    end

    def formatted_discount
      if promotion_type == 'percentage'
        "#{discount_amount}%"
      else
        "$#{discount_amount}"
      end
    end

    private

    def end_date_after_start_date
      return if ends_at.blank? || starts_at.blank?

      if ends_at < starts_at
        errors.add(:ends_at, "must be after the start date")
      end
    end

    def vendor_or_platform_wide
      if vendor_id.present? && !Komplex.configuration.allow_vendor_promotions
        errors.add(:vendor_id, "vendor promotions are not allowed")
      end
    end
  end
end