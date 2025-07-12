# frozen_string_literal: true

module Komplex
  module Admin
    class VendorsController < Spree::Admin::ResourceController
      before_action :load_data, except: [:index, :new, :create]

      def index
        @vendors = Komplex::Vendor.all.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def approve
        @vendor = Komplex::Vendor.find(params[:id])
        if @vendor.approve!
          flash[:success] = t('komplex.admin.vendors.approve.success')
          Komplex::ApprovalNotificationWorker.perform_async('Komplex::Vendor', @vendor.id, 'approved')
        else
          flash[:error] = t('komplex.admin.vendors.approve.error')
        end
        redirect_to admin_vendors_path
      end

      def reject
        @vendor = Komplex::Vendor.find(params[:id])
        if @vendor.reject!
          flash[:success] = t('komplex.admin.vendors.reject.success')
          Komplex::ApprovalNotificationWorker.perform_async('Komplex::Vendor', @vendor.id, 'rejected')
        else
          flash[:error] = t('komplex.admin.vendors.reject.error')
        end
        redirect_to admin_vendors_path
      end

      def listings
        @vendor = Komplex::Vendor.find(params[:id])
        @listings = @vendor.listings.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def commissions
        @vendor = Komplex::Vendor.find(params[:id])
        @commissions = @vendor.commissions.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def payouts
        @vendor = Komplex::Vendor.find(params[:id])
        @payouts = @vendor.payouts.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def create_payout
        @vendor = Komplex::Vendor.find(params[:id])
        amount = params[:amount].to_f
        
        if amount <= 0
          flash[:error] = t('komplex.admin.vendors.create_payout.invalid_amount')
          redirect_to payouts_admin_vendor_path(@vendor) and return
        end
        
        payout = Komplex::Payout.create_for_vendor(@vendor, amount: amount, notes: params[:notes])
        
        if payout&.persisted?
          flash[:success] = t('komplex.admin.vendors.create_payout.success', amount: amount)
          payout.process!
        else
          flash[:error] = t('komplex.admin.vendors.create_payout.error')
        end
        
        redirect_to payouts_admin_vendor_path(@vendor)
      end

      private

      def load_data
        @users = Spree::User.all
      end

      def model_class
        Komplex::Vendor
      end
    end
  end
end