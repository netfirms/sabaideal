# frozen_string_literal: true

module Komplex
  module Admin
    class PayoutsController < Komplex::Admin::BaseController
      before_action :load_data, except: [:index, :show]

      def index
        @payouts = Komplex::Payout.all

        # Apply filters
        @payouts = @payouts.by_vendor(params[:vendor_id]) if params[:vendor_id].present?
        @payouts = @payouts.where(status: params[:status]) if params[:status].present?

        # Apply date filters
        if params[:start_date].present? && params[:end_date].present?
          start_date = Date.parse(params[:start_date])
          end_date = Date.parse(params[:end_date])
          @payouts = @payouts.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
        end

        # Apply sorting
        case params[:sort]
        when 'newest'
          @payouts = @payouts.order(created_at: :desc)
        when 'oldest'
          @payouts = @payouts.order(created_at: :asc)
        when 'amount_high'
          @payouts = @payouts.order(amount: :desc)
        when 'amount_low'
          @payouts = @payouts.order(amount: :asc)
        else
          @payouts = @payouts.order(created_at: :desc)
        end

        @payouts = @payouts.page(params[:page]).per(Komplex.configuration.admin_products_per_page)
      end

      def show
        @payout = Komplex::Payout.find(params[:id])
        @vendor = @payout.vendor
        @commissions = Komplex::Commission.where(vendor_id: @vendor.id, status: 'paid', paid_at: @payout.created_at)
      end

      def new
        @payout = Komplex::Payout.new
      end

      def create
        @vendor = Komplex::Vendor.find(payout_params[:vendor_id])
        amount = payout_params[:amount].to_f

        if amount <= 0
          flash[:error] = t('komplex.admin.payouts.create.invalid_amount')
          redirect_to new_admin_payout_path and return
        end

        payout = Komplex::Payout.create_for_vendor(@vendor, amount: amount, notes: payout_params[:notes])

        if payout&.persisted?
          flash[:success] = t('komplex.admin.payouts.create.success', amount: amount)
          payout.process!
          redirect_to admin_payouts_path
        else
          flash.now[:error] = t('komplex.admin.payouts.create.error')
          load_data
          render :new
        end
      end

      def process_payout
        @payout = Komplex::Payout.find(params[:id])

        if @payout.process!
          flash[:success] = t('komplex.admin.payouts.process.success')
        else
          flash[:error] = t('komplex.admin.payouts.process.error')
        end

        redirect_to admin_payout_path(@payout)
      end

      def mark_as_completed
        @payout = Komplex::Payout.find(params[:id])
        transaction_id = params[:transaction_id] || "manual-#{SecureRandom.hex(6)}"

        if @payout.mark_as_completed!(transaction_id)
          flash[:success] = t('komplex.admin.payouts.mark_as_completed.success')
        else
          flash[:error] = t('komplex.admin.payouts.mark_as_completed.error')
        end

        redirect_to admin_payout_path(@payout)
      end

      def mark_as_failed
        @payout = Komplex::Payout.find(params[:id])

        if @payout.mark_as_failed!(params[:failure_reason])
          flash[:success] = t('komplex.admin.payouts.mark_as_failed.success')
        else
          flash[:error] = t('komplex.admin.payouts.mark_as_failed.error')
        end

        redirect_to admin_payout_path(@payout)
      end

      private

      def load_data
        @vendors = Komplex::Vendor.approved
      end

      def model_class
        Komplex::Payout
      end

      def payout_params
        params.require(:payout).permit(
          :vendor_id, :amount, :notes
        )
      end
    end
  end
end
