# frozen_string_literal: true

module Komplex
  class Listing < ApplicationRecord
    belongs_to :vendor
    belongs_to :listable, polymorphic: true, dependent: :destroy
    has_many :reviews, dependent: :destroy
    has_many :promotions, dependent: :nullify
    has_many :advertisements, dependent: :nullify
    has_many :conversations, dependent: :destroy

    has_one_attached :main_image
    has_many_attached :additional_images

    validates :title, presence: true
    validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    enum :status, {
      draft: 'draft',
      pending: 'pending',
      published: 'published',
      rejected: 'rejected',
      archived: 'archived'
    }

    scope :active, -> { published }
    scope :featured, -> { where(featured: true) }
    scope :by_type, ->(type) { where(listable_type: "Komplex::#{type.to_s.classify}") }
    scope :by_vendor, ->(vendor_id) { where(vendor_id: vendor_id) }
    scope :recent, -> { order(created_at: :desc) }

    before_save :set_published_at, if: -> { status_changed? && published? && published_at.nil? }

    def submit_for_approval!
      update(status: :pending)
      AdminMailer.new_listing_notification(self).deliver_later
    end

    def approve!
      update(status: :published)
      VendorMailer.listing_approval_notification(self).deliver_later
    end

    def reject!(reason = nil)
      update(status: :rejected, rejection_reason: reason)
      VendorMailer.listing_rejection_notification(self).deliver_later
    end

    def archive!
      update(status: :archived)
    end

    def active?
      published?
    end

    def average_rating
      reviews.approved.average(:rating) || 0
    end

    def to_param
      "#{id}-#{title.parameterize}"
    end

    def property?
      listable_type == 'Komplex::Property'
    end

    def restaurant?
      listable_type == 'Komplex::Restaurant'
    end

    def service?
      listable_type == 'Komplex::Service'
    end

    def type
      listable_type.to_s.demodulize
    end

    private

    def set_published_at
      self.published_at = Time.current
    end
  end
end
