# frozen_string_literal: true

module Komplex
  module Storefront
    class VendorsController < ::Spree::StoreController
      before_action :authenticate_spree_user!, except: [:index, :show]
      before_action :set_vendor, only: [:show, :edit, :update]
      before_action :ensure_vendor_owner, only: [:edit, :update]

      def index
        @vendors = Komplex::Vendor.approved.page(params[:page]).per(24)
      end

      def show
        @listings = @vendor.listings.published.page(params[:page]).per(12)
      end

      def new
        # Check if user already has a vendor account
        if current_spree_user.vendor.present?
          redirect_to vendor_path(current_spree_user.vendor), notice: t('komplex.storefront.vendors.already_registered')
          return
        end

        @vendor = Komplex::Vendor.new
      end

      def create
        # Check if user already has a vendor account
        if current_spree_user.vendor.present?
          redirect_to vendor_path(current_spree_user.vendor), notice: t('komplex.storefront.vendors.already_registered')
          return
        end

        @vendor = Komplex::Vendor.new(vendor_params)
        @vendor.user = current_spree_user
        @vendor.status = Komplex.configuration.vendor_approval_required ? 'pending' : 'approved'

        if @vendor.save
          if @vendor.approved?
            redirect_to vendor_dashboard_path, notice: t('komplex.storefront.vendors.create.success_approved')
          else
            redirect_to root_path, notice: t('komplex.storefront.vendors.create.success_pending')
          end
        else
          flash.now[:error] = t('komplex.storefront.vendors.create.error')
          render :new
        end
      end

      def edit
      end

      def update
        if @vendor.update(vendor_params)
          redirect_to vendor_path(@vendor), notice: t('komplex.storefront.vendors.update.success')
        else
          flash.now[:error] = t('komplex.storefront.vendors.update.error')
          render :edit
        end
      end

      def dashboard
        @vendor = current_spree_user.vendor
        
        unless @vendor
          redirect_to new_vendor_path, notice: t('komplex.storefront.vendors.register_first')
          return
        end

        unless @vendor.approved?
          redirect_to root_path, notice: t('komplex.storefront.vendors.pending_approval')
          return
        end

        @listings = @vendor.listings.page(params[:page]).per(10)
        @pending_listings = @vendor.listings.pending.count
        @published_listings = @vendor.listings.published.count
        @total_sales = @vendor.total_sales
        @pending_payout = @vendor.pending_payout_amount
      end

      private

      def set_vendor
        @vendor = Komplex::Vendor.approved.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = t('komplex.storefront.vendors.not_found')
        redirect_to vendors_path
      end

      def ensure_vendor_owner
        unless current_spree_user.vendor == @vendor
          flash[:error] = t('komplex.storefront.vendors.unauthorized')
          redirect_to vendors_path
        end
      end

      def vendor_params
        params.require(:vendor).permit(:name, :description)
      end
    end
  end
end