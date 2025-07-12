# frozen_string_literal: true

module Komplex
  class MessageMailer < ApplicationMailer
    def new_buyer_message(message)
      @message = message
      @conversation = message.conversation
      @sender = message.sender
      @recipient = @conversation.vendor.user
      @listing = @conversation.listing

      mail(
        to: @recipient.email,
        subject: I18n.t('komplex.message_mailer.new_buyer_message.subject', 
                        listing: @listing.title, 
                        sender: @sender.display_name)
      )
    end

    def new_vendor_message(message)
      @message = message
      @conversation = message.conversation
      @sender = message.sender
      @recipient = @conversation.buyer
      @listing = @conversation.listing
      @vendor = @conversation.vendor

      mail(
        to: @recipient.email,
        subject: I18n.t('komplex.message_mailer.new_vendor_message.subject', 
                        listing: @listing.title, 
                        vendor: @vendor.name)
      )
    end

    def conversation_summary(conversation, recipient)
      @conversation = conversation
      @recipient = recipient
      @listing = conversation.listing
      @messages = conversation.messages.order(created_at: :desc).limit(10)
      
      if recipient.id == conversation.buyer_id
        @other_party = conversation.vendor.name
      else
        @other_party = conversation.buyer.display_name
      end

      mail(
        to: @recipient.email,
        subject: I18n.t('komplex.message_mailer.conversation_summary.subject', 
                        listing: @listing.title, 
                        other_party: @other_party)
      )
    end

    def unread_messages_reminder(user)
      @user = user
      @unread_count = user.unread_messages_count
      
      # Get conversations with unread messages
      if user.vendor?
        @conversations = user.vendor.conversations.joins(:messages)
                            .where(komplex_messages: { read: false })
                            .where.not(komplex_messages: { sender_id: user.id })
                            .distinct
      else
        @conversations = user.buyer_conversations.joins(:messages)
                            .where(komplex_messages: { read: false })
                            .where.not(komplex_messages: { sender_id: user.id })
                            .distinct
      end

      return if @conversations.empty?

      mail(
        to: @user.email,
        subject: I18n.t('komplex.message_mailer.unread_messages_reminder.subject', count: @unread_count)
      )
    end
  end
end