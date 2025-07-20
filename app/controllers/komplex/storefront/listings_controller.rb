module Komplex
  module Storefront
    class ListingsController < Spree::StoreController
      before_action :load_listing, only: [:show]
      before_action :ensure_merchant, only: [:new, :create, :edit, :update, :destroy, :my_listings]

      def index
        @listings = Komplex::Listing.published.page(params[:page]).per(12)

        if params[:search].present?
          @listings = @listings.where("title ILIKE ? OR description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
        end

        if params[:category_id].present?
          @listings = @listings.joins(:categories).where(komplex_categories: { id: params[:category_id] })
        end

        if params[:min_price].present?
          @listings = @listings.where("price >= ?", params[:min_price])
        end

        if params[:max_price].present?
          @listings = @listings.where("price <= ?", params[:max_price])
        end

        if params[:sort].present?
          case params[:sort]
          when 'price_asc'
            @listings = @listings.order(price: :asc)
          when 'price_desc'
            @listings = @listings.order(price: :desc)
          when 'newest'
            @listings = @listings.order(created_at: :desc)
          when 'oldest'
            @listings = @listings.order(created_at: :asc)
          end
        else
          @listings = @listings.order(created_at: :desc)
        end
      end

      def show
        @related_listings = @listing.merchant.listings.published.where.not(id: @listing.id).limit(4)
      end

      def new
        @listing = Komplex::Listing.new
        @listing.merchant = current_merchant
      end

      def create
        @listing = Komplex::Listing.new(listing_params)
        @listing.merchant = current_merchant
        @listing.status = 'pending'

        if @listing.save
          flash[:success] = "Your listing has been submitted and is pending approval."
          redirect_to my_listings_path
        else
          flash.now[:error] = @listing.errors.full_messages.join(", ")
          render :new
        end
      end

      def edit
        @listing = current_merchant.listings.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Listing not found or you don't have permission to edit it."
        redirect_to my_listings_path
      end

      def update
        @listing = current_merchant.listings.find(params[:id])

        if @listing.update(listing_params)
          @listing.update(status: 'pending')
          flash[:success] = "Your listing has been updated and is pending approval."
          redirect_to my_listings_path
        else
          flash.now[:error] = @listing.errors.full_messages.join(", ")
          render :edit
        end
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Listing not found or you don't have permission to edit it."
        redirect_to my_listings_path
      end

      def destroy
        @listing = current_merchant.listings.find(params[:id])

        if @listing.destroy
          flash[:success] = "Listing was successfully deleted."
        else
          flash[:error] = "Listing could not be deleted."
        end
        redirect_to my_listings_path
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Listing not found or you don't have permission to delete it."
        redirect_to my_listings_path
      end

      def my_listings
        @listings = current_merchant.listings.order(created_at: :desc).page(params[:page]).per(10)
      end

      private

      def load_listing
        @listing = Komplex::Listing.published.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Listing not found or not published yet."
        redirect_to listings_path
      end

      def ensure_merchant
        unless current_merchant
          flash[:error] = "You need to be a merchant to access this page."
          redirect_to new_merchant_path
        end
      end

      def current_merchant
        @current_merchant ||= spree_current_user&.merchant
      end

      def listing_params
        params.require(:listing).permit(:title, :description, :price, :featured, :listable_type, :listable_id, :condition, :category)
      end
    end
  end
end
