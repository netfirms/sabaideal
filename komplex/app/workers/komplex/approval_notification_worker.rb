# frozen_string_literal: true

module Komplex
  class ApprovalNotificationWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'komplex_notifications', retry: 3

    def perform(resource_type, resource_id, status)
      resource_class = resource_type.constantize
      resource = resource_class.find(resource_id)
      
      case resource_type
      when 'Komplex::Vendor'
        notify_vendor(resource, status)
      when 'Komplex::Listing'
        notify_listing_owner(resource, status)
      when 'Komplex::Review'
        notify_review_owner(resource, status)
      when 'Komplex::Advertisement'
        notify_advertisement_owner(resource, status)
      end
    end

    private

    def notify_vendor(vendor, status)
      case status
      when 'approved'
        VendorMailer.approval_notification(vendor).deliver_now
      when 'rejected'
        VendorMailer.rejection_notification(vendor).deliver_now
      end
    end

    def notify_listing_owner(listing, status)
      case status
      when 'published'
        ListingMailer.approval_notification(listing).deliver_now
      when 'rejected'
        ListingMailer.rejection_notification(listing).deliver_now
      end
    end

    def notify_review_owner(review, status)
      case status
      when 'approved'
        ReviewMailer.approval_notification(review).deliver_now
      when 'rejected'
        ReviewMailer.rejection_notification(review).deliver_now
      end
    end

    def notify_advertisement_owner(advertisement, status)
      case status
      when 'active'
        AdvertisementMailer.approval_notification(advertisement).deliver_now
      when 'rejected'
        AdvertisementMailer.rejection_notification(advertisement).deliver_now
      end
    end
  end
end