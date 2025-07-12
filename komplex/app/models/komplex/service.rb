# frozen_string_literal: true

module Komplex
  class Service < ApplicationRecord
    has_one :listing, as: :listable, dependent: :destroy
    belongs_to :category

    validates :pricing_model, presence: true
    validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :duration_minutes, numericality: { greater_than: 0 }, allow_nil: true

    scope :by_category, ->(category_id) { where(category_id: category_id) }
    scope :by_pricing_model, ->(model) { where(pricing_model: model) }
    scope :with_remote_option, -> { where(remote_available: true) }
    scope :by_price_range, ->(min, max = nil) {
      if max.present?
        where('price >= ? AND price <= ?', min, max)
      else
        where('price >= ?', min)
      end
    }
    scope :by_duration, ->(min, max = nil) {
      if max.present?
        where('duration_minutes >= ? AND duration_minutes <= ?', min, max)
      else
        where('duration_minutes >= ?', min)
      end
    }

    def hourly?
      pricing_model == 'hourly'
    end

    def fixed_price?
      pricing_model == 'fixed'
    end

    def duration_in_hours
      return nil if duration_minutes.blank?

      (duration_minutes / 60.0).round(1)
    end

    def formatted_duration
      return nil if duration_minutes.blank?

      hours = duration_minutes / 60
      minutes = duration_minutes % 60

      if hours > 0 && minutes > 0
        "#{hours}h #{minutes}m"
      elsif hours > 0
        "#{hours}h"
      else
        "#{minutes}m"
      end
    end

    def price_with_unit
      return nil if price.blank?

      if hourly?
        "#{price}/hour"
      else
        price.to_s
      end
    end
  end
end