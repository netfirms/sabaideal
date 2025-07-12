# frozen_string_literal: true

module Komplex
  class VendorMailer < ApplicationMailer
    def approval_notification(vendor)
      @vendor = vendor
      @user = vendor.user
      @store = vendor.store

      mail(
        to: @user.email,
        subject: I18n.t('komplex.vendor_mailer.approval_notification.subject')
      )
    end

    def rejection_notification(vendor)
      @vendor = vendor
      @user = vendor.user
      @rejection_reason = vendor.rejection_reason

      mail(
        to: @user.email,
        subject: I18n.t('komplex.vendor_mailer.rejection_notification.subject')
      )
    end

    def welcome(vendor)
      @vendor = vendor
      @user = vendor.user

      mail(
        to: @user.email,
        subject: I18n.t('komplex.vendor_mailer.welcome.subject')
      )
    end

    def new_listing_inquiry(listing, inquiry)
      @vendor = listing.vendor
      @user = @vendor.user
      @listing = listing
      @inquiry = inquiry
      @buyer = inquiry.sender

      mail(
        to: @user.email,
        subject: I18n.t('komplex.vendor_mailer.new_listing_inquiry.subject', listing: @listing.title)
      )
    end

    def new_order_notification(order, vendor)
      @vendor = vendor
      @user = vendor.user
      @order = order
      @vendor_items = order.line_items.select { |item| item.product.vendor_id == vendor.id }

      mail(
        to: @user.email,
        subject: I18n.t('komplex.vendor_mailer.new_order_notification.subject', order: @order.number)
      )
    end

    def commission_notification(commission)
      @vendor = commission.vendor
      @user = @vendor.user
      @commission = commission
      @order = commission.order

      mail(
        to: @user.email,
        subject: I18n.t('komplex.vendor_mailer.commission_notification.subject', order: @order.number)
      )
    end
  end
end