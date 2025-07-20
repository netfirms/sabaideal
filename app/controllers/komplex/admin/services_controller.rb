module Komplex
  module Admin
    class ServicesController < Spree::Admin::ResourceController
      before_action :load_service, only: [:show, :edit, :update, :destroy, :approve_listing, :reject_listing]

      def index
        @services = Komplex::Service.all.page(params[:page]).per(10)
      end

      def new
        @service = Komplex::Service.new
        @service.build_listing
      end

      def create
        @service = Komplex::Service.new(service_params)

        # Set default values for required listing attributes if not provided
        if @service.listing
          @service.listing.condition ||= 'new'
          @service.listing.category ||= 'service'
        end

        if @service.save
          flash[:success] = "Service listing was successfully created."
          redirect_to spree.admin_services_path
        else
          # Ensure listing is built for the form
          @service.build_listing if @service.listing.nil?
          flash.now[:error] = @service.errors.full_messages.join(", ")
          render :new
        end
      end

      def show
      end

      def edit
        # Ensure listing is built for the form
        @service.build_listing if @service.listing.nil?
      end

      def update
        # Get the service params
        updated_params = service_params

        # Set default values for required listing attributes if not provided
        if updated_params[:listing_attributes]
          updated_params[:listing_attributes][:condition] ||= 'new'
          updated_params[:listing_attributes][:category] ||= 'service'
        end

        if @service.update(updated_params)
          flash[:success] = "Service listing was successfully updated."
          redirect_to spree.admin_services_path
        else
          flash.now[:error] = @service.errors.full_messages.join(", ")
          render :edit
        end
      end

      def destroy
        if @service.destroy
          flash[:success] = "Service listing was successfully deleted."
        else
          flash[:error] = "Service listing could not be deleted."
        end
        redirect_to spree.admin_services_path
      end

      def approve_listing
        if @service.listing&.pending?
          if @service.listing.publish!
            flash[:success] = "Service listing has been approved and published."
          else
            flash[:error] = "Failed to approve service listing."
          end
        else
          flash[:error] = "Only pending listings can be approved."
        end
        redirect_to spree.admin_service_path(@service)
      end

      def reject_listing
        if @service.listing&.pending?
          if @service.listing.reject!
            flash[:success] = "Service listing has been rejected."
          else
            flash[:error] = "Failed to reject service listing."
          end
        else
          flash[:error] = "Only pending listings can be rejected."
        end
        redirect_to spree.admin_service_path(@service)
      end

      private

      def load_service
        @service = Komplex::Service.find(params[:id])
      end

      def service_params
        params.require(:service).permit(
          :pricing_model, :duration_minutes, :service_area, :remote_available, :category_id,
          listing_attributes: [:id, :title, :description, :price, :merchant_id, :status, :featured, :condition, :category]
        )
      end
    end
  end
end
