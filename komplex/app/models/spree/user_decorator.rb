# frozen_string_literal: true

module Spree
  module UserDecorator
    def self.prepended(base)
      base.has_one :vendor, class_name: 'Komplex::Vendor', dependent: :destroy
      base.has_many :listings, through: :vendor, class_name: 'Komplex::Listing'
      base.has_many :reviews, class_name: 'Komplex::Review', dependent: :destroy
      base.has_many :buyer_conversations, class_name: 'Komplex::Conversation', foreign_key: 'buyer_id', dependent: :destroy
      base.has_many :sent_messages, class_name: 'Komplex::Message', foreign_key: 'sender_id', dependent: :destroy
    end

    def vendor?
      vendor.present?
    end

    def approved_vendor?
      vendor? && vendor.approved?
    end

    def pending_vendor?
      vendor? && vendor.pending?
    end

    def rejected_vendor?
      vendor? && vendor.rejected?
    end

    def vendor_conversations
      return Komplex::Conversation.none unless vendor?

      Komplex::Conversation.where(vendor_id: vendor.id)
    end

    def all_conversations
      Komplex::Conversation.where('buyer_id = ? OR vendor_id = ?', id, vendor&.id)
    end

    def unread_messages_count
      return 0 unless vendor? || buyer_conversations.exists?

      # Count unread messages where user is the recipient
      Komplex::Message.joins(:conversation)
                      .where('(komplex_conversations.buyer_id = ? AND komplex_messages.sender_id != ?) OR 
                             (komplex_conversations.vendor_id = ? AND komplex_messages.sender_id != ?)',
                             id, id, vendor&.id, id)
                      .where(read: false)
                      .count
    end

    def can_review?(listing)
      # Users can review listings they haven't already reviewed
      # In a real implementation, you might also check if they've purchased/booked the listing
      !reviews.exists?(listing_id: listing.id)
    end

    def display_name
      full_name.presence || email.split('@').first
    end

    def full_name
      [first_name, last_name].compact.join(' ').presence
    end
  end
end

Spree::User.prepend Spree::UserDecorator if defined?(Spree::User)