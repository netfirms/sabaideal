# frozen_string_literal: true

module Komplex
  class Conversation < ApplicationRecord
    belongs_to :listing
    belongs_to :buyer, class_name: 'Spree::User'
    belongs_to :vendor
    has_many :messages, dependent: :destroy

    validates :listing_id, :buyer_id, :vendor_id, presence: true
    validate :buyer_not_vendor

    scope :active, -> { where(status: 'active') }
    scope :archived, -> { where(status: 'archived') }
    scope :by_listing, ->(listing_id) { where(listing_id: listing_id) }
    scope :by_buyer, ->(buyer_id) { where(buyer_id: buyer_id) }
    scope :by_vendor, ->(vendor_id) { where(vendor_id: vendor_id) }
    scope :recent, -> { order(updated_at: :desc) }
    scope :with_unread_messages, -> { joins(:messages).where(komplex_messages: { read: false }) }

    enum :status, {
      active: 'active',
      archived: 'archived'
    }

    def archive!
      update(status: :archived)
    end

    def activate!
      update(status: :active)
    end

    def active?
      status == 'active'
    end

    def archived?
      status == 'archived'
    end

    def unread_messages_for(user)
      messages.where.not(sender: user).where(read: false)
    end

    def mark_as_read_for(user)
      unread_messages_for(user).update_all(read: true)
    end

    def last_message
      messages.order(created_at: :desc).first
    end

    def add_message(user, content)
      messages.create(sender: user, content: content)
    end

    private

    def buyer_not_vendor
      if buyer_id.present? && vendor.present? && vendor.user_id == buyer_id
        errors.add(:buyer_id, "cannot be the same as the vendor")
      end
    end
  end
end
