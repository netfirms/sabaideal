module Komplex
  module Admin
    class RealEstatePropertiesController < Spree::Admin::ResourceController
      before_action :load_property, only: [:show, :edit, :update, :destroy, :approve_listing, :reject_listing]

      def index
        @properties = Komplex::RealEstateProperty.all.page(params[:page]).per(10)
      end

      def new
        @property = Komplex::RealEstateProperty.new
        @property.build_listing
      end

      def create
        @property = Komplex::RealEstateProperty.new(property_params)

        # Set default values for required listing attributes if not provided
        if @property.listing
          @property.listing.condition ||= 'new'
          @property.listing.category ||= 'property'
        end

        if @property.save
          flash[:success] = "Property listing was successfully created."
          redirect_to spree.admin_real_estate_properties_path
        else
          # Ensure listing is built for the form
          @property.build_listing if @property.listing.nil?
          flash.now[:error] = @property.errors.full_messages.join(", ")
          render :new
        end
      end

      def show
      end

      def edit
        # Ensure listing is built for the form
        @property.build_listing if @property.listing.nil?
      end

      def update
        # Get the property params
        updated_params = property_params

        # Set default values for required listing attributes if not provided
        if updated_params[:listing_attributes]
          updated_params[:listing_attributes][:condition] ||= 'new'
          updated_params[:listing_attributes][:category] ||= 'property'
        end

        if @property.update(updated_params)
          flash[:success] = "Property listing was successfully updated."
          redirect_to spree.admin_real_estate_properties_path
        else
          flash.now[:error] = @property.errors.full_messages.join(", ")
          render :edit
        end
      end

      def destroy
        if @property.destroy
          flash[:success] = "Property listing was successfully deleted."
        else
          flash[:error] = "Property listing could not be deleted."
        end
        redirect_to spree.admin_real_estate_properties_path
      end

      def approve_listing
        if @property.listing&.pending?
          if @property.listing.publish!
            flash[:success] = "Property listing has been approved and published."
          else
            flash[:error] = "Failed to approve property listing."
          end
        else
          flash[:error] = "Only pending listings can be approved."
        end
        redirect_to spree.admin_real_estate_property_path(@property)
      end

      def reject_listing
        if @property.listing&.pending?
          if @property.listing.reject!
            flash[:success] = "Property listing has been rejected."
          else
            flash[:error] = "Failed to reject property listing."
          end
        else
          flash[:error] = "Only pending listings can be rejected."
        end
        redirect_to spree.admin_real_estate_property_path(@property)
      end

      private

      def load_property
        @property = Komplex::RealEstateProperty.find(params[:id])
      end

      def property_params
        params.require(:property).permit(
          :property_type, :listing_type, :bedrooms, :bathrooms, :area, :area_unit,
          :address, :city, :state, :postal_code, :country, :latitude, :longitude,
          :furnished, :available_from,
          listing_attributes: [:id, :title, :description, :price, :merchant_id, :status, :featured, :condition, :category]
        )
      end
    end
  end
end
