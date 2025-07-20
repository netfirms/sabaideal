module Komplex
  module Admin
    class ListingsController < Spree::Admin::ResourceController
      before_action :load_listing, only: [:show, :edit, :update, :destroy, :approve, :reject]

      def index
        @listings = Komplex::Listing.all.page(params[:page]).per(10)
      end

      def new
        @listing = Komplex::Listing.new
      end

      def create
        @listing = Komplex::Listing.new(listing_params)
        if @listing.save
          flash[:success] = "Listing was successfully created."
          redirect_to spree.admin_listing_path(@listing)
        else
          flash.now[:error] = @listing.errors.full_messages.join(", ")
          render :new
        end
      end

      def show
      end

      def edit
      end

      def update
        if @listing.update(listing_params)
          flash[:success] = "Listing was successfully updated."
          redirect_to spree.admin_listing_path(@listing)
        else
          flash.now[:error] = @listing.errors.full_messages.join(", ")
          render :edit
        end
      end

      def destroy
        if @listing.destroy
          flash[:success] = "Listing was successfully deleted."
        else
          flash[:error] = "Listing could not be deleted."
        end
        redirect_to spree.admin_listings_path
      end

      def approve
        @listing.update(status: 'published', published_at: Time.current)
        flash[:success] = "Listing was successfully approved and published."
        redirect_to spree.admin_listings_path
      end

      def reject
        @listing.update(status: 'rejected')
        flash[:success] = "Listing was successfully rejected."
        redirect_to spree.admin_listings_path
      end

      private

      def load_listing
        @listing = Komplex::Listing.find(params[:id])
      end

      def listing_params
        params.require(:listing).permit(:title, :description, :price, :merchant_id, :status, :featured, :listable_type, :listable_id, :condition, :category)
      end
    end
  end
end
