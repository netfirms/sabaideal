module Komplex
  module Admin
    class MerchantsController < Spree::Admin::ResourceController
      before_action :load_merchant, only: [:show, :edit, :update, :destroy, :approve, :reject]

      def index
        @merchants = Komplex::Merchant.all.page(params[:page]).per(10)
      end

      def new
        @merchant = Komplex::Merchant.new
      end

      def create
        @merchant = Komplex::Merchant.new(merchant_params)
        if @merchant.save
          flash[:success] = "Merchant was successfully created."
          redirect_to spree.admin_merchants_path
        else
          flash.now[:error] = @merchant.errors.full_messages.join(", ")
          render :new
        end
      end

      def show
      end

      def edit
      end

      def update
        if @merchant.update(merchant_params)
          flash[:success] = "Merchant was successfully updated."
          redirect_to spree.admin_merchants_path
        else
          flash.now[:error] = @merchant.errors.full_messages.join(", ")
          render :edit
        end
      end

      def destroy
        if @merchant.destroy
          flash[:success] = "Merchant was successfully deleted."
        else
          flash[:error] = "Merchant could not be deleted."
        end
        redirect_to spree.admin_merchants_path
      end

      def approve
        @merchant.update(status: 'approved')
        flash[:success] = "Merchant was successfully approved."
        redirect_to spree.admin_merchants_path
      end

      def reject
        @merchant.update(status: 'rejected')
        flash[:success] = "Merchant was successfully rejected."
        redirect_to spree.admin_merchants_path
      end

      private

      def load_merchant
        @merchant = Komplex::Merchant.find(params[:id])
      end

      def merchant_params
        params.require(:komplex_merchant).permit(:name, :description, :user_id, :commission_rate, :status)
      end
    end
  end
end
