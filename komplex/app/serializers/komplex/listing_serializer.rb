# frozen_string_literal: true

module Komplex
  class ListingSerializer < Spree::BaseSerializer
    set_type :listing

    attributes :title, :description, :price, :status, :featured, :published_at, :created_at, :updated_at

    attribute :active do |listing|
      listing.active?
    end

    attribute :average_rating do |listing|
      listing.average_rating
    end

    attribute :listing_type do |listing|
      listing.listable_type.demodulize.downcase
    end

    attribute :main_image_url do |listing, params|
      if listing.main_image.attached?
        Rails.application.routes.url_helpers.rails_blob_url(listing.main_image, host: params[:host])
      end
    end

    attribute :additional_image_urls do |listing, params|
      if listing.additional_images.attached?
        listing.additional_images.map do |image|
          Rails.application.routes.url_helpers.rails_blob_url(image, host: params[:host])
        end
      else
        []
      end
    end

    belongs_to :vendor, serializer: :vendor
    has_many :reviews, serializer: :review
    has_many :promotions, serializer: :promotion
    has_many :advertisements, serializer: :advertisement
    has_many :conversations, serializer: :conversation

    # Polymorphic relationship to the specific listing type
    belongs_to :listable, polymorphic: true do |listing|
      case listing.listable_type
      when 'Komplex::Property'
        :property
      when 'Komplex::Restaurant'
        :restaurant
      when 'Komplex::Service'
        :service
      end
    end
  end
end