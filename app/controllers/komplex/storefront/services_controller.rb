module Komplex
  module Storefront
    class ServicesController < Spree::StoreController
      before_action :load_service, only: [:show]
      before_action :ensure_merchant, only: [:new, :create, :edit, :update, :destroy, :my_services]

      def index
        @services = Komplex::Service.joins(:listing).where(komplex_listings: { status: 'published' }).page(params[:page]).per(12)

        if params[:search].present?
          @services = @services.joins(:listing).where("komplex_listings.title ILIKE ? OR komplex_listings.description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
        end

        if params[:category_id].present?
          @services = @services.where(category_id: params[:category_id])
        end

        if params[:pricing_model].present?
          @services = @services.where(pricing_model: params[:pricing_model])
        end

        if params[:remote_available].present?
          @services = @services.where(remote_available: params[:remote_available] == 'true')
        end

        if params[:min_price].present?
          @services = @services.joins(:listing).where("komplex_listings.price >= ?", params[:min_price])
        end

        if params[:max_price].present?
          @services = @services.joins(:listing).where("komplex_listings.price <= ?", params[:max_price])
        end

        if params[:sort].present?
          case params[:sort]
          when 'price_asc'
            @services = @services.joins(:listing).order("komplex_listings.price ASC")
          when 'price_desc'
            @services = @services.joins(:listing).order("komplex_listings.price DESC")
          when 'newest'
            @services = @services.joins(:listing).order("komplex_listings.created_at DESC")
          end
        else
          @services = @services.joins(:listing).order("komplex_listings.created_at DESC")
        end
      end

      def show
        @related_services = Komplex::Service.joins(:listing)
                                          .where(komplex_listings: { status: 'published' })
                                          .where(category_id: @service.category_id)
                                          .where.not(id: @service.id)
                                          .limit(4)
      end

      def new
        @service = Komplex::Service.new
        @service.build_listing
        @service.listing.merchant = current_merchant
      end

      def create
        @service = Komplex::Service.new(service_params)
        @service.listing.merchant = current_merchant
        @service.listing.status = 'pending'
        @service.listing.listable = @service
        @service.listing.condition = 'new'
        @service.listing.category = 'service'

        if @service.save
          flash[:success] = "Your service listing has been submitted and is pending approval."
          redirect_to my_services_path
        else
          flash.now[:error] = @service.errors.full_messages.join(", ")
          render :new
        end
      end

      def edit
        @service = Komplex::Service.joins(:listing).where(komplex_listings: { merchant_id: current_merchant.id }).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Service not found or you don't have permission to edit it."
        redirect_to my_services_path
      end

      def update
        @service = Komplex::Service.joins(:listing).where(komplex_listings: { merchant_id: current_merchant.id }).find(params[:id])

        # Merge the status update into the service_params
        updated_params = service_params
        if updated_params[:listing_attributes]
          updated_params[:listing_attributes][:status] = 'pending'
          updated_params[:listing_attributes][:condition] = 'new'
          updated_params[:listing_attributes][:category] = 'service'
        end

        if @service.update(updated_params)
          flash[:success] = "Your service listing has been updated and is pending approval."
          redirect_to my_services_path
        else
          flash.now[:error] = @service.errors.full_messages.join(", ")
          render :edit
        end
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Service not found or you don't have permission to edit it."
        redirect_to my_services_path
      end

      def destroy
        @service = Komplex::Service.joins(:listing).where(komplex_listings: { merchant_id: current_merchant.id }).find(params[:id])

        if @service.destroy
          flash[:success] = "Service listing was successfully deleted."
        else
          flash[:error] = "Service listing could not be deleted."
        end
        redirect_to my_services_path
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Service not found or you don't have permission to delete it."
        redirect_to my_services_path
      end

      def my_services
        @services = Komplex::Service.joins(:listing).where(komplex_listings: { merchant_id: current_merchant.id }).page(params[:page]).per(10)
      end

      private

      def load_service
        @service = Komplex::Service.joins(:listing).where(komplex_listings: { status: 'published' }).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Service not found or not published yet."
        redirect_to services_path
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

      def service_params
        params.require(:service).permit(
          :pricing_model, :duration_minutes, :service_area, :remote_available, :category_id,
          listing_attributes: [:id, :title, :description, :price, :featured]
        )
      end
    end
  end
end