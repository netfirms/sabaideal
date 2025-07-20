module Komplex
  module Storefront
    class RealEstatePropertiesController < Spree::StoreController
      before_action :load_property, only: [:show]
      before_action :ensure_merchant, only: [:new, :create, :edit, :update, :destroy, :my_properties]

      def index
        @properties = Komplex::RealEstateProperty.joins(:listing).where(komplex_listings: { status: 'published' }).page(params[:page]).per(12)

        if params[:search].present?
          @properties = @properties.joins(:listing).where("komplex_listings.title ILIKE ? OR komplex_listings.description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
        end

        if params[:property_type].present?
          @properties = @properties.where(property_type: params[:property_type])
        end

        if params[:listing_type].present?
          @properties = @properties.where(listing_type: params[:listing_type])
        end

        if params[:bedrooms].present?
          @properties = @properties.where(bedrooms: params[:bedrooms])
        end

        if params[:bathrooms].present?
          @properties = @properties.where(bathrooms: params[:bathrooms])
        end

        if params[:min_price].present?
          @properties = @properties.joins(:listing).where("komplex_listings.price >= ?", params[:min_price])
        end

        if params[:max_price].present?
          @properties = @properties.joins(:listing).where("komplex_listings.price <= ?", params[:max_price])
        end

        if params[:city].present?
          @properties = @properties.where("city ILIKE ?", "%#{params[:city]}%")
        end

        if params[:furnished].present?
          @properties = @properties.where(furnished: params[:furnished] == 'true')
        end

        if params[:sort].present?
          case params[:sort]
          when 'price_asc'
            @properties = @properties.joins(:listing).order("komplex_listings.price ASC")
          when 'price_desc'
            @properties = @properties.joins(:listing).order("komplex_listings.price DESC")
          when 'newest'
            @properties = @properties.joins(:listing).order("komplex_listings.created_at DESC")
          when 'bedrooms_asc'
            @properties = @properties.order(bedrooms: :asc)
          when 'bedrooms_desc'
            @properties = @properties.order(bedrooms: :desc)
          when 'area_asc'
            @properties = @properties.order(area: :asc)
          when 'area_desc'
            @properties = @properties.order(area: :desc)
          end
        else
          @properties = @properties.joins(:listing).order("komplex_listings.created_at DESC")
        end
      end

      def show
        @related_properties = Komplex::RealEstateProperty.joins(:listing)
                                              .where(komplex_listings: { status: 'published' })
                                              .where(property_type: @property.property_type)
                                              .where.not(id: @property.id)
                                              .limit(4)
      end

      def new
        @property = Komplex::RealEstateProperty.new
        @property.build_listing
        @property.listing.merchant = current_merchant
      end

      def create
        @property = Komplex::RealEstateProperty.new(property_params)
        @property.listing.merchant = current_merchant
        @property.listing.status = 'pending'
        @property.listing.listable = @property

        if @property.save
          flash[:success] = "Your property listing has been submitted and is pending approval."
          redirect_to my_real_estate_properties_path
        else
          flash.now[:error] = @property.errors.full_messages.join(", ")
          render :new
        end
      end

      def edit
        @property = Komplex::RealEstateProperty.joins(:listing).where(komplex_listings: { merchant_id: current_merchant.id }).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Property not found or you don't have permission to edit it."
        redirect_to my_real_estate_properties_path
      end

      def update
        @property = Komplex::RealEstateProperty.joins(:listing).where(komplex_listings: { merchant_id: current_merchant.id }).find(params[:id])

        # Merge the status update into the property_params
        updated_params = property_params
        if updated_params[:listing_attributes]
          updated_params[:listing_attributes][:status] = 'pending'
        end

        if @property.update(updated_params)
          flash[:success] = "Your property listing has been updated and is pending approval."
          redirect_to my_real_estate_properties_path
        else
          flash.now[:error] = @property.errors.full_messages.join(", ")
          render :edit
        end
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Property not found or you don't have permission to edit it."
        redirect_to my_real_estate_properties_path
      end

      def destroy
        @property = Komplex::RealEstateProperty.joins(:listing).where(komplex_listings: { merchant_id: current_merchant.id }).find(params[:id])

        if @property.destroy
          flash[:success] = "Property listing was successfully deleted."
        else
          flash[:error] = "Property listing could not be deleted."
        end
        redirect_to my_real_estate_properties_path
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Property not found or you don't have permission to delete it."
        redirect_to my_real_estate_properties_path
      end

      def my_properties
        @properties = Komplex::RealEstateProperty.joins(:listing).where(komplex_listings: { merchant_id: current_merchant.id }).page(params[:page]).per(10)
      end

      private

      def load_property
        @property = Komplex::RealEstateProperty.joins(:listing).where(komplex_listings: { status: 'published' }).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Property not found or not published yet."
        redirect_to real_estate_properties_path
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

      def property_params
        params.require(:property).permit(
          :property_type, :listing_type, :bedrooms, :bathrooms, :area, :area_unit,
          :address, :city, :state, :postal_code, :country, :latitude, :longitude,
          :furnished, :available_from,
          listing_attributes: [:id, :title, :description, :price, :featured]
        )
      end
    end
  end
end
