# frozen_string_literal: true

module Komplex
  module Storefront
    class ListingsController < ::Spree::StoreController
      before_action :authenticate_spree_user!, except: [:index, :show, :search]
      before_action :ensure_vendor, except: [:index, :show, :search]
      before_action :set_listing, only: [:show, :edit, :update, :destroy, :submit_for_approval]
      before_action :ensure_listing_owner, only: [:edit, :update, :destroy, :submit_for_approval]

      def index
        @listings = Komplex::Listing.published
        
        # Apply filters
        @listings = apply_filters(@listings)
        
        # Apply sorting
        @listings = apply_sorting(@listings)
        
        @listings = @listings.page(params[:page]).per(24)
      end

      def show
        # Ensure the listing is published or belongs to the current user
        unless @listing.published? || (current_spree_user && current_spree_user.vendor == @listing.vendor)
          flash[:error] = t('komplex.storefront.listings.not_available')
          redirect_to listings_path
          return
        end

        @vendor = @listing.vendor
        @related_listings = Komplex::Listing.published
                                           .where(listable_type: @listing.listable_type)
                                           .where.not(id: @listing.id)
                                           .limit(4)
      end

      def new
        @listing_type = params[:type]
        
        unless ['Property', 'Restaurant', 'Service'].include?(@listing_type)
          flash[:error] = t('komplex.storefront.listings.invalid_type')
          redirect_to vendor_dashboard_path
          return
        end
        
        @listing = Komplex::Listing.new
        
        case @listing_type
        when 'Property'
          @listing.build_property
        when 'Restaurant'
          @listing.build_restaurant
        when 'Service'
          @listing.build_service
          @categories = Komplex::Category.all
        end
      end

      def create
        @listing = Komplex::Listing.new(listing_params)
        @listing.vendor = current_spree_user.vendor
        @listing.status = 'draft'
        
        if @listing.save
          if params[:submit_for_approval].present?
            @listing.submit_for_approval!
            redirect_to vendor_dashboard_path, notice: t('komplex.storefront.listings.create.submitted')
          else
            redirect_to edit_listing_path(@listing), notice: t('komplex.storefront.listings.create.draft')
          end
        else
          @listing_type = @listing.listable_type.demodulize
          
          case @listing_type
          when 'Property'
            @listing.build_property unless @listing.property
          when 'Restaurant'
            @listing.build_restaurant unless @listing.restaurant
          when 'Service'
            @listing.build_service unless @listing.service
            @categories = Komplex::Category.all
          end
          
          flash.now[:error] = t('komplex.storefront.listings.create.error')
          render :new
        end
      end

      def edit
        @listing_type = @listing.listable_type.demodulize
        
        case @listing_type
        when 'Service'
          @categories = Komplex::Category.all
        end
      end

      def update
        if @listing.update(listing_params)
          if params[:submit_for_approval].present? && @listing.draft?
            @listing.submit_for_approval!
            redirect_to vendor_dashboard_path, notice: t('komplex.storefront.listings.update.submitted')
          else
            redirect_to listing_path(@listing), notice: t('komplex.storefront.listings.update.success')
          end
        else
          @listing_type = @listing.listable_type.demodulize
          
          case @listing_type
          when 'Service'
            @categories = Komplex::Category.all
          end
          
          flash.now[:error] = t('komplex.storefront.listings.update.error')
          render :edit
        end
      end

      def destroy
        if @listing.destroy
          redirect_to vendor_dashboard_path, notice: t('komplex.storefront.listings.destroy.success')
        else
          redirect_to vendor_dashboard_path, error: t('komplex.storefront.listings.destroy.error')
        end
      end

      def submit_for_approval
        if @listing.draft?
          if @listing.submit_for_approval!
            redirect_to vendor_dashboard_path, notice: t('komplex.storefront.listings.submit_for_approval.success')
          else
            redirect_to vendor_dashboard_path, error: t('komplex.storefront.listings.submit_for_approval.error')
          end
        else
          redirect_to vendor_dashboard_path, error: t('komplex.storefront.listings.submit_for_approval.invalid_status')
        end
      end

      def search
        @listings = Komplex::Listing.published
        
        # Apply search query
        if params[:q].present?
          @listings = @listings.where('title ILIKE ? OR description ILIKE ?', "%#{params[:q]}%", "%#{params[:q]}%")
        end
        
        # Apply filters
        @listings = apply_filters(@listings)
        
        # Apply sorting
        @listings = apply_sorting(@listings)
        
        @listings = @listings.page(params[:page]).per(24)
        
        render :index
      end

      private

      def set_listing
        @listing = Komplex::Listing.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = t('komplex.storefront.listings.not_found')
        redirect_to listings_path
      end

      def ensure_vendor
        unless current_spree_user.vendor.present? && current_spree_user.vendor.approved?
          flash[:error] = t('komplex.storefront.listings.vendor_required')
          redirect_to new_vendor_path
        end
      end

      def ensure_listing_owner
        unless current_spree_user.vendor == @listing.vendor
          flash[:error] = t('komplex.storefront.listings.unauthorized')
          redirect_to listings_path
        end
      end

      def apply_filters(listings)
        # Filter by listing type
        listings = listings.by_type(params[:type]) if params[:type].present?
        
        # Filter by vendor
        listings = listings.by_vendor(params[:vendor_id]) if params[:vendor_id].present?
        
        # Filter by featured status
        listings = listings.featured if params[:featured] == 'true'
        
        # Filter by price range
        if params[:min_price].present?
          listings = listings.where('price >= ?', params[:min_price])
        end
        
        if params[:max_price].present?
          listings = listings.where('price <= ?', params[:max_price])
        end
        
        # Apply type-specific filters
        case params[:type]
        when 'Property'
          listings = apply_property_filters(listings)
        when 'Restaurant'
          listings = apply_restaurant_filters(listings)
        when 'Service'
          listings = apply_service_filters(listings)
        end
        
        listings
      end

      def apply_property_filters(listings)
        return listings unless params[:type] == 'Property'
        
        # Join with properties table
        listings = listings.joins('INNER JOIN komplex_properties ON komplex_properties.listing_id = komplex_listings.id')
        
        # Apply property-specific filters
        listings = listings.where('komplex_properties.property_type = ?', params[:property_type]) if params[:property_type].present?
        listings = listings.where('komplex_properties.listing_type = ?', params[:listing_type]) if params[:listing_type].present?
        listings = listings.where('komplex_properties.bedrooms >= ?', params[:bedrooms]) if params[:bedrooms].present?
        listings = listings.where('komplex_properties.bathrooms >= ?', params[:bathrooms]) if params[:bathrooms].present?
        listings = listings.where('komplex_properties.city ILIKE ?', "%#{params[:city]}%") if params[:city].present?
        
        listings
      end

      def apply_restaurant_filters(listings)
        return listings unless params[:type] == 'Restaurant'
        
        # Join with restaurants table
        listings = listings.joins('INNER JOIN komplex_restaurants ON komplex_restaurants.listing_id = komplex_listings.id')
        
        # Apply restaurant-specific filters
        listings = listings.where('komplex_restaurants.cuisine_type = ?', params[:cuisine_type]) if params[:cuisine_type].present?
        listings = listings.where('komplex_restaurants.city ILIKE ?', "%#{params[:city]}%") if params[:city].present?
        
        listings
      end

      def apply_service_filters(listings)
        return listings unless params[:type] == 'Service'
        
        # Join with services table
        listings = listings.joins('INNER JOIN komplex_services ON komplex_services.listing_id = komplex_listings.id')
        
        # Apply service-specific filters
        listings = listings.where('komplex_services.category_id = ?', params[:category_id]) if params[:category_id].present?
        listings = listings.where('komplex_services.pricing_model = ?', params[:pricing_model]) if params[:pricing_model].present?
        
        listings
      end

      def apply_sorting(listings)
        case params[:sort]
        when 'newest'
          listings.order(created_at: :desc)
        when 'oldest'
          listings.order(created_at: :asc)
        when 'price_asc'
          listings.order(price: :asc)
        when 'price_desc'
          listings.order(price: :desc)
        else
          listings.order(created_at: :desc)
        end
      end

      def listing_params
        case params[:listing][:listable_type]
        when 'Komplex::Property'
          params.require(:listing).permit(
            :title, :description, :price, :listable_type,
            property_attributes: [
              :id, :property_type, :listing_type, :bedrooms, :bathrooms,
              :area, :area_unit, :address, :city, :state, :postal_code,
              :country, :latitude, :longitude, :furnished, :available_from
            ],
            images: []
          )
        when 'Komplex::Restaurant'
          params.require(:listing).permit(
            :title, :description, :price, :listable_type,
            restaurant_attributes: [
              :id, :cuisine_type, :address, :city, :state, :postal_code,
              :country, :latitude, :longitude, :delivery_available,
              :takeout_available, :reservation_required
            ],
            images: []
          )
        when 'Komplex::Service'
          params.require(:listing).permit(
            :title, :description, :price, :listable_type,
            service_attributes: [
              :id, :category_id, :pricing_model, :price, :duration_minutes,
              :service_area, :remote_available
            ],
            images: []
          )
        else
          params.require(:listing).permit(:title, :description, :price, :listable_type, images: [])
        end
      end
    end
  end
end