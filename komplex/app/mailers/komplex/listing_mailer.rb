# frozen_string_literal: true

module Komplex
  class ListingMailer < ApplicationMailer
    def approval_notification(listing)
      @listing = listing
      @vendor = listing.vendor
      @user = @vendor.user

      mail(
        to: @user.email,
        subject: I18n.t('komplex.listing_mailer.approval_notification.subject', title: @listing.title)
      )
    end

    def rejection_notification(listing)
      @listing = listing
      @vendor = listing.vendor
      @user = @vendor.user
      @rejection_reason = listing.rejection_reason

      mail(
        to: @user.email,
        subject: I18n.t('komplex.listing_mailer.rejection_notification.subject', title: @listing.title)
      )
    end

    def new_review_notification(review)
      @review = review
      @listing = review.listing
      @vendor = @listing.vendor
      @user = @vendor.user
      @reviewer = review.user

      mail(
        to: @user.email,
        subject: I18n.t('komplex.listing_mailer.new_review_notification.subject', title: @listing.title)
      )
    end

    def featured_listing_notification(listing)
      @listing = listing
      @vendor = listing.vendor
      @user = @vendor.user

      mail(
        to: @user.email,
        subject: I18n.t('komplex.listing_mailer.featured_listing_notification.subject', title: @listing.title)
      )
    end

    def expiring_listing_notification(listing)
      @listing = listing
      @vendor = listing.vendor
      @user = @vendor.user
      @days_until_expiry = ((listing.expires_at - Time.current) / 1.day).to_i

      mail(
        to: @user.email,
        subject: I18n.t('komplex.listing_mailer.expiring_listing_notification.subject', 
                        title: @listing.title, 
                        days: @days_until_expiry)
      )
    end

    def listing_expired_notification(listing)
      @listing = listing
      @vendor = listing.vendor
      @user = @vendor.user

      mail(
        to: @user.email,
        subject: I18n.t('komplex.listing_mailer.listing_expired_notification.subject', title: @listing.title)
      )
    end
  end
end