# frozen_string_literal: true

module Komplex
  class Review < ApplicationRecord
    belongs_to :listing
    belongs_to :user, class_name: 'Spree::User'

    validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
    validates :user_id, uniqueness: { scope: :listing_id, message: "has already reviewed this listing" }

    scope :approved, -> { where(approved: true) }
    scope :pending_approval, -> { where(approved: false) }
    scope :by_listing, ->(listing_id) { where(listing_id: listing_id) }
    scope :by_user, ->(user_id) { where(user_id: user_id) }
    scope :recent, -> { order(created_at: :desc) }
    scope :highest_rated, -> { order(rating: :desc) }
    scope :lowest_rated, -> { order(rating: :asc) }

    after_save :update_listing_average_rating, if: :saved_change_to_approved?

    def approve!
      update(approved: true)
    end

    def reject!
      update(approved: false)
    end

    def pending?
      !approved?
    end

    def stars
      "★" * rating + "☆" * (5 - rating)
    end

    private

    def update_listing_average_rating
      listing.update_average_rating if listing.respond_to?(:update_average_rating)
    end
  end
end