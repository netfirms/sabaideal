# frozen_string_literal: true

module Komplex
  module Admin
    class ListingsController < Spree::Admin::ResourceController
      before_action :load_data, except: [:index, :new, :create]

      def index
        @listings = Komplex::Listing.all
        
        # Apply filters
        @listings = @listings.by_type(params[:type]) if params[:type].present?
        @listings = @listings.by_vendor(params[:vendor_id]) if params[:vendor_id].present?
        @listings = @listings.where(status: params[:status]) if params[:status].present?
        
        # Apply sorting
        case params[:sort]
        when 'newest'
          @listings = @listings.order(created_at: :desc)
        when 'oldest'
          @listings = @listings.order(created_at: :asc)
        when 'price_asc'
          @listings = @listings.order(price: :asc)
        when 'price_desc'
          @listings = @listings.order(price: :desc)
        else
          @listings = @listings.order(created_at: :desc)
        end
        
        @listings = @listings.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def approve
        @listing = Komplex::Listing.find(params[:id])
        if @listing.approve!
          flash[:success] = t('komplex.admin.listings.approve.success')
          Komplex::ApprovalNotificationWorker.perform_async('Komplex::Listing', @listing.id, 'published')
        else
          flash[:error] = t('komplex.admin.listings.approve.error')
        end
        redirect_to admin_listings_path
      end

      def reject
        @listing = Komplex::Listing.find(params[:id])
        if @listing.reject!(params[:rejection_reason])
          flash[:success] = t('komplex.admin.listings.reject.success')
          Komplex::ApprovalNotificationWorker.perform_async('Komplex::Listing', @listing.id, 'rejected')
        else
          flash[:error] = t('komplex.admin.listings.reject.error')
        end
        redirect_to admin_listings_path
      end

      def feature
        @listing = Komplex::Listing.find(params[:id])
        if @listing.update(featured: true)
          flash[:success] = t('komplex.admin.listings.feature.success')
        else
          flash[:error] = t('komplex.admin.listings.feature.error')
        end
        redirect_to admin_listings_path
      end

      def unfeature
        @listing = Komplex::Listing.find(params[:id])
        if @listing.update(featured: false)
          flash[:success] = t('komplex.admin.listings.unfeature.success')
        else
          flash[:error] = t('komplex.admin.listings.unfeature.error')
        end
        redirect_to admin_listings_path
      end

      def reviews
        @listing = Komplex::Listing.find(params[:id])
        @reviews = @listing.reviews.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def convert_to_product
        @listing = Komplex::Listing.find(params[:id])
        product = @listing.to_spree_product
        
        if product.persisted?
          flash[:success] = t('komplex.admin.listings.convert_to_product.success')
          redirect_to edit_admin_product_path(product)
        else
          flash[:error] = t('komplex.admin.listings.convert_to_product.error')
          redirect_to admin_listings_path
        end
      end

      private

      def load_data
        @vendors = Komplex::Vendor.all
        @listing_types = ['Property', 'Restaurant', 'Service']
        @statuses = Komplex::Listing.statuses.keys
      end

      def model_class
        Komplex::Listing
      end
    end
  end
end