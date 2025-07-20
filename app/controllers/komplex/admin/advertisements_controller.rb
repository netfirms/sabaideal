module Komplex
  module Admin
    class AdvertisementsController < Spree::Admin::ResourceController
      before_action :load_advertisement, only: [:show, :edit, :update, :destroy, :approve_listing, :reject_listing]

      def index
        @advertisements = Komplex::Advertisement.all.page(params[:page]).per(10)
      end

      def new
        @advertisement = Komplex::Advertisement.new
        @advertisement.build_listing
      end

      def create
        @advertisement = Komplex::Advertisement.new(advertisement_params)

        # Set default values for required listing attributes if not provided
        if @advertisement.listing
          @advertisement.listing.condition ||= 'new'
          @advertisement.listing.category ||= 'advertisement'
        end

        if @advertisement.save
          flash[:success] = "Advertisement was successfully created."
          redirect_to spree.admin_advertisements_path
        else
          # Ensure listing is built for the form
          @advertisement.build_listing if @advertisement.listing.nil?
          flash.now[:error] = @advertisement.errors.full_messages.join(", ")
          render :new
        end
      end

      def show
      end

      def edit
        # Ensure listing is built for the form
        @advertisement.build_listing if @advertisement.listing.nil?
      end

      def update
        # Get the advertisement params
        updated_params = advertisement_params

        # Set default values for required listing attributes if not provided
        if updated_params[:listing_attributes]
          updated_params[:listing_attributes][:condition] ||= 'new'
          updated_params[:listing_attributes][:category] ||= 'advertisement'
        end

        if @advertisement.update(updated_params)
          flash[:success] = "Advertisement was successfully updated."
          redirect_to spree.admin_advertisements_path
        else
          flash.now[:error] = @advertisement.errors.full_messages.join(", ")
          render :edit
        end
      end

      def destroy
        if @advertisement.destroy
          flash[:success] = "Advertisement was successfully deleted."
        else
          flash[:error] = "Advertisement could not be deleted."
        end
        redirect_to spree.admin_advertisements_path
      end

      def approve_listing
        if @advertisement.listing&.pending?
          if @advertisement.listing.publish!
            flash[:success] = "Advertisement listing has been approved and published."
          else
            flash[:error] = "Failed to approve advertisement listing."
          end
        else
          flash[:error] = "Only pending listings can be approved."
        end
        redirect_to spree.admin_advertisement_path(@advertisement)
      end

      def reject_listing
        if @advertisement.listing&.pending?
          if @advertisement.listing.reject!
            flash[:success] = "Advertisement listing has been rejected."
          else
            flash[:error] = "Failed to reject advertisement listing."
          end
        else
          flash[:error] = "Only pending listings can be rejected."
        end
        redirect_to spree.admin_advertisement_path(@advertisement)
      end

      private

      def load_advertisement
        @advertisement = Komplex::Advertisement.find(params[:id])
      end

      def advertisement_params
        params.require(:advertisement).permit(
          :title, :description, :placement, :ad_type, :merchant_id, :starts_at, :ends_at, :cost, :status,
          listing_attributes: [:id, :title, :description, :price, :merchant_id, :status, :featured, :condition, :category]
        )
      end
    end
  end
end
