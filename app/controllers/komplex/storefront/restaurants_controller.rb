module Komplex
  module Storefront
    class RestaurantsController < Spree::StoreController
      before_action :load_restaurant, only: [:show]
      before_action :ensure_merchant, only: [:new, :create, :edit, :update, :destroy, :my_restaurants]

      def index
        @restaurants = Komplex::Restaurant.joins(:listing).where(komplex_listings: { status: 'published' }).page(params[:page]).per(12)
        
        if params[:search].present?
          @restaurants = @restaurants.joins(:listing).where("komplex_listings.title ILIKE ? OR komplex_listings.description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
        end
        
        if params[:cuisine_type].present?
          @restaurants = @restaurants.where(cuisine_type: params[:cuisine_type])
        end
        
        if params[:delivery_available].present?
          @restaurants = @restaurants.where(delivery_available: params[:delivery_available] == 'true')
        end
        
        if params[:takeout_available].present?
          @restaurants = @restaurants.where(takeout_available: params[:takeout_available] == 'true')
        end
        
        if params[:reservation_required].present?
          @restaurants = @restaurants.where(reservation_required: params[:reservation_required] == 'true')
        end
        
        if params[:min_price].present?
          @restaurants = @restaurants.joins(:listing).where("komplex_listings.price >= ?", params[:min_price])
        end
        
        if params[:max_price].present?
          @restaurants = @restaurants.joins(:listing).where("komplex_listings.price <= ?", params[:max_price])
        end
        
        if params[:city].present?
          @restaurants = @restaurants.where("city ILIKE ?", "%#{params[:city]}%")
        end
        
        if params[:sort].present?
          case params[:sort]
          when 'price_asc'
            @restaurants = @restaurants.joins(:listing).order("komplex_listings.price ASC")
          when 'price_desc'
            @restaurants = @restaurants.joins(:listing).order("komplex_listings.price DESC")
          when 'newest'
            @restaurants = @restaurants.joins(:listing).order("komplex_listings.created_at DESC")
          end
        else
          @restaurants = @restaurants.joins(:listing).order("komplex_listings.created_at DESC")
        end
      end

      def show
        @related_restaurants = Komplex::Restaurant.joins(:listing)
                                                .where(komplex_listings: { status: 'published' })
                                                .where(cuisine_type: @restaurant.cuisine_type)
                                                .where.not(id: @restaurant.id)
                                                .limit(4)
      end

      def new
        @restaurant = Komplex::Restaurant.new
        @restaurant.build_listing
        @restaurant.listing.merchant = current_merchant
      end

      def create
        @restaurant = Komplex::Restaurant.new(restaurant_params)
        @restaurant.listing.merchant = current_merchant
        @restaurant.listing.status = 'pending'
        @restaurant.listing.listable = @restaurant

        if @restaurant.save
          flash[:success] = "Your restaurant listing has been submitted and is pending approval."
          redirect_to my_restaurants_path
        else
          flash.now[:error] = @restaurant.errors.full_messages.join(", ")
          render :new
        end
      end

      def edit
        @restaurant = Komplex::Restaurant.joins(:listing).where(komplex_listings: { merchant_id: current_merchant.id }).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Restaurant not found or you don't have permission to edit it."
        redirect_to my_restaurants_path
      end

      def update
        @restaurant = Komplex::Restaurant.joins(:listing).where(komplex_listings: { merchant_id: current_merchant.id }).find(params[:id])
        
        if @restaurant.update(restaurant_params)
          @restaurant.listing.update(status: 'pending')
          flash[:success] = "Your restaurant listing has been updated and is pending approval."
          redirect_to my_restaurants_path
        else
          flash.now[:error] = @restaurant.errors.full_messages.join(", ")
          render :edit
        end
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Restaurant not found or you don't have permission to edit it."
        redirect_to my_restaurants_path
      end

      def destroy
        @restaurant = Komplex::Restaurant.joins(:listing).where(komplex_listings: { merchant_id: current_merchant.id }).find(params[:id])
        
        if @restaurant.destroy
          flash[:success] = "Restaurant listing was successfully deleted."
        else
          flash[:error] = "Restaurant listing could not be deleted."
        end
        redirect_to my_restaurants_path
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Restaurant not found or you don't have permission to delete it."
        redirect_to my_restaurants_path
      end

      def my_restaurants
        @restaurants = Komplex::Restaurant.joins(:listing).where(komplex_listings: { merchant_id: current_merchant.id }).page(params[:page]).per(10)
      end

      private

      def load_restaurant
        @restaurant = Komplex::Restaurant.joins(:listing).where(komplex_listings: { status: 'published' }).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Restaurant not found or not published yet."
        redirect_to restaurants_path
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

      def restaurant_params
        params.require(:restaurant).permit(
          :cuisine_type, :menu_items, :opening_hours, :address, :city, :state, 
          :postal_code, :country, :latitude, :longitude, :delivery_available, 
          :takeout_available, :reservation_required,
          listing_attributes: [:title, :description, :price, :featured]
        )
      end
    end
  end
end