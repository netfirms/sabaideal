# frozen_string_literal: true

module Komplex
  class Restaurant < ApplicationRecord
    has_one :listing, as: :listable, dependent: :destroy

    validates :address, :city, :country, presence: true

    scope :by_cuisine_type, ->(type) { where(cuisine_type: type) }
    scope :by_city, ->(city) { where('city ILIKE ?', "%#{city}%") }
    scope :with_delivery, -> { where(delivery_available: true) }
    scope :with_takeout, -> { where(takeout_available: true) }
    scope :with_reservations, -> { where(reservation_required: true) }

    def full_address
      [address, city, state, postal_code, country].compact.join(', ')
    end

    def open_now?
      return false if opening_hours.blank?

      current_time = Time.current
      day_of_week = current_time.strftime('%A').downcase
      return false unless opening_hours[day_of_week].present?

      opening_hours[day_of_week].any? do |hours|
        open_time = Time.parse(hours['open'])
        close_time = Time.parse(hours['close'])
        current_time_of_day = current_time.strftime('%H:%M')
        current_time_of_day >= open_time.strftime('%H:%M') && current_time_of_day <= close_time.strftime('%H:%M')
      end
    end

    def opening_hours_for_day(day)
      return [] if opening_hours.blank? || opening_hours[day.to_s.downcase].blank?

      opening_hours[day.to_s.downcase]
    end

    def add_menu_item(name, description, price, category = nil)
      item = {
        'name' => name,
        'description' => description,
        'price' => price
      }
      item['category'] = category if category.present?

      self.menu_items = [] if menu_items.nil?
      self.menu_items << item
      save
    end

    def menu_items_by_category
      return {} if menu_items.blank?

      menu_items.group_by { |item| item['category'] || 'Uncategorized' }
    end
  end
end