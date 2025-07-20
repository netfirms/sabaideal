module Komplex
  module Storefront
    class MerchantsController < Spree::StoreController
      before_action :load_merchant, only: [:show]

      def index
        @merchants = Komplex::Merchant.approved.page(params[:page]).per(12)
      end

      def show
        @listings = @merchant.listings.published.page(params[:page]).per(9)
      end

      def new
        redirect_to login_path unless spree_current_user
        @merchant = Komplex::Merchant.new
      end

      def create
        @merchant = Komplex::Merchant.new(merchant_params)
        @merchant.user = spree_current_user
        @merchant.status = 'pending'

        if @merchant.save
          flash[:success] = "Your merchant application has been submitted and is pending approval."
          redirect_to account_path
        else
          flash.now[:error] = @merchant.errors.full_messages.join(", ")
          render :new
        end
      end

      private

      def load_merchant
        @merchant = Komplex::Merchant.approved.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Merchant not found or not approved yet."
        redirect_to merchants_path
      end

      def merchant_params
        params.require(:merchant).permit(:name, :description, :logo)
      end
    end
  end
end
