# frozen_string_literal: true

module Komplex
  class Message < ApplicationRecord
    belongs_to :conversation
    belongs_to :sender, class_name: 'Spree::User'

    validates :content, presence: true
    validates :conversation_id, :sender_id, presence: true

    scope :unread, -> { where(read: false) }
    scope :read, -> { where(read: true) }
    scope :by_conversation, ->(conversation_id) { where(conversation_id: conversation_id) }
    scope :by_sender, ->(sender_id) { where(sender_id: sender_id) }
    scope :chronological, -> { order(created_at: :asc) }
    scope :recent_first, -> { order(created_at: :desc) }

    after_create :update_conversation_timestamp
    after_create :send_notification

    def mark_as_read!
      update(read: true)
    end

    def mark_as_unread!
      update(read: false)
    end

    def from_buyer?
      sender_id == conversation.buyer_id
    end

    def from_vendor?
      sender_id == conversation.vendor.user_id
    end

    def recipient
      from_buyer? ? conversation.vendor.user : conversation.buyer
    end

    private

    def update_conversation_timestamp
      conversation.touch
    end

    def send_notification
      MessageNotificationWorker.perform_async(id)
    end
  end
end