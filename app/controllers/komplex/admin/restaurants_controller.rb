module Komplex
  module Admin
    class RestaurantsController < Spree::Admin::ResourceController
      before_action :load_restaurant, only: [:show, :edit, :update, :destroy]

      def index
        @restaurants = Komplex::Restaurant.all.page(params[:page]).per(10)
      end

      def new
        @restaurant = Komplex::Restaurant.new
        @restaurant.build_listing(condition: 'new', category: 'restaurant')
      end

      def create
        @restaurant = Komplex::Restaurant.new(restaurant_params)
        @restaurant.listing.listable = @restaurant if @restaurant.listing

        # Ensure condition and category are set
        if @restaurant.listing && @restaurant.listing.condition.blank?
          @restaurant.listing.condition = 'new'
        end

        if @restaurant.listing && @restaurant.listing.category.blank?
          @restaurant.listing.category = 'restaurant'
        end

        if @restaurant.save
          flash[:success] = "Restaurant listing was successfully created."
          redirect_to spree.admin_restaurants_path
        else
          flash.now[:error] = @restaurant.errors.full_messages.join(", ")
          render :new
        end
      end

      def show
      end

      def edit
      end

      def update
        restaurant_attrs = restaurant_params

        # Ensure condition and category are set if listing is being updated
        if restaurant_attrs[:listing_attributes]
          if restaurant_attrs[:listing_attributes][:condition].blank?
            restaurant_attrs[:listing_attributes][:condition] = 'new'
          end

          if restaurant_attrs[:listing_attributes][:category].blank?
            restaurant_attrs[:listing_attributes][:category] = 'restaurant'
          end
        end

        if @restaurant.update(restaurant_attrs)
          flash[:success] = "Restaurant listing was successfully updated."
          redirect_to spree.admin_restaurants_path
        else
          flash.now[:error] = @restaurant.errors.full_messages.join(", ")
          render :edit
        end
      end

      def destroy
        if @restaurant.destroy
          flash[:success] = "Restaurant listing was successfully deleted."
        else
          flash[:error] = "Restaurant listing could not be deleted."
        end
        redirect_to spree.admin_restaurants_path
      end

      private

      def load_restaurant
        @restaurant = Komplex::Restaurant.find(params[:id])
      end

      def restaurant_params
        params.require(:restaurant).permit(
          :cuisine_type, :menu_items, :opening_hours, :address, :city, :state, 
          :postal_code, :country, :latitude, :longitude, :delivery_available, 
          :takeout_available, :reservation_required,
          listing_attributes: [:title, :description, :price, :merchant_id, :status, :featured, :condition, :category]
        )
      end
    end
  end
end
