# frozen_string_literal: true

module Komplex
  class VendorSerializer < Spree::BaseSerializer
    set_type :vendor

    attributes :name, :description, :status, :commission_rate, :settings, :created_at, :updated_at

    attribute :active do |vendor|
      vendor.active?
    end

    attribute :total_listings do |vendor|
      vendor.listings.count
    end

    attribute :published_listings do |vendor|
      vendor.published_listings.count
    end

    attribute :total_sales do |vendor|
      vendor.total_sales
    end

    attribute :total_commission_paid do |vendor|
      vendor.total_commission_paid
    end

    attribute :pending_payout_amount do |vendor|
      vendor.pending_payout_amount
    end

    belongs_to :user, serializer: :user, record_type: :user
    has_many :listings, serializer: :listing
    has_many :promotions, serializer: :promotion
    has_many :advertisements, serializer: :advertisement
    has_many :commissions, serializer: :commission
    has_many :payouts, serializer: :payout
  end
end