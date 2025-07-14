# frozen_string_literal: true

module Komplex
  module Admin
    class VendorsController < Komplex::Admin::BaseController
      before_action :load_data, except: [:index]

      def index
        @vendors = Komplex::Vendor.all.page(params[:page]).per(Komplex.configuration.admin_products_per_page)
      end

      def new
        @vendor = Komplex::Vendor.new
      end

      def create
        @vendor = Komplex::Vendor.new(permitted_resource_params)

        if @vendor.save
          flash[:success] = t('komplex.admin.vendors.create.success')
          redirect_to admin_vendors_path
        else
          flash.now[:error] = t('komplex.admin.vendors.create.error')
          load_data
          render :new
        end
      end

      def edit
        @vendor = Komplex::Vendor.find(params[:id])
      end

      def update
        @vendor = Komplex::Vendor.find(params[:id])

        if @vendor.update(permitted_resource_params)
          flash[:success] = t('komplex.admin.vendors.update.success')
          redirect_to admin_vendors_path
        else
          flash.now[:error] = t('komplex.admin.vendors.update.error')
          load_data
          render :edit
        end
      end

      def show
        @vendor = Komplex::Vendor.find(params[:id])
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
        @listings = @vendor.listings.page(params[:page]).per(Komplex.configuration.admin_products_per_page)
      end

      def commissions
        @vendor = Komplex::Vendor.find(params[:id])
        @commissions = @vendor.commissions.page(params[:page]).per(Komplex.configuration.admin_products_per_page)
      end

      def payouts
        @vendor = Komplex::Vendor.find(params[:id])
        @payouts = @vendor.payouts.page(params[:page]).per(Komplex.configuration.admin_products_per_page)
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
        @statuses = Komplex::Vendor.statuses.keys
      end

      def model_class
        Komplex::Vendor
      end

      def permitted_resource_params
        params.require(:vendor).permit(
          :user_id, :name, :description, :status, :commission_rate, settings: {}
        )
      end
    end
  end
end
