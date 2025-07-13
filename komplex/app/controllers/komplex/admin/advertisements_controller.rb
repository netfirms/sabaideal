# frozen_string_literal: true

module Komplex
  module Admin
    class AdvertisementsController < Komplex::Admin::BaseController
      before_action :load_data, except: [:index, :destroy]

      def index
        @advertisements = Komplex::Advertisement.all

        # Apply filters
        @advertisements = @advertisements.by_vendor(params[:vendor_id]) if params[:vendor_id].present?
        @advertisements = @advertisements.by_placement(params[:placement]) if params[:placement].present?
        @advertisements = @advertisements.by_ad_type(params[:ad_type]) if params[:ad_type].present?
        @advertisements = @advertisements.where(status: params[:status]) if params[:status].present?

        # Apply date filters
        if params[:current] == 'true'
          @advertisements = @advertisements.active
        elsif params[:expired] == 'true'
          @advertisements = @advertisements.where('ends_at < ?', Time.current)
        elsif params[:upcoming] == 'true'
          @advertisements = @advertisements.where('starts_at > ?', Time.current)
        end

        # Apply sorting
        case params[:sort]
        when 'newest'
          @advertisements = @advertisements.order(created_at: :desc)
        when 'oldest'
          @advertisements = @advertisements.order(created_at: :asc)
        when 'starts_soon'
          @advertisements = @advertisements.order(starts_at: :asc)
        when 'ends_soon'
          @advertisements = @advertisements.order(ends_at: :asc)
        else
          @advertisements = @advertisements.order(created_at: :desc)
        end

        @advertisements = @advertisements.page(params[:page]).per(Komplex.configuration.admin_products_per_page)
      end

      def approve
        @advertisement = Komplex::Advertisement.find(params[:id])
        if @advertisement.approve!
          flash[:success] = t('komplex.admin.advertisements.approve.success')
          Komplex::ApprovalNotificationWorker.perform_async('Komplex::Advertisement', @advertisement.id, 'active')
        else
          flash[:error] = t('komplex.admin.advertisements.approve.error')
        end
        redirect_to admin_advertisements_path
      end

      def reject
        @advertisement = Komplex::Advertisement.find(params[:id])
        if @advertisement.reject!(params[:rejection_reason])
          flash[:success] = t('komplex.admin.advertisements.reject.success')
          Komplex::ApprovalNotificationWorker.perform_async('Komplex::Advertisement', @advertisement.id, 'rejected')
        else
          flash[:error] = t('komplex.admin.advertisements.reject.error')
        end
        redirect_to admin_advertisements_path
      end

      def new
        @advertisement = Komplex::Advertisement.new
        @advertisement.starts_at = Time.current
        @advertisement.ends_at = 30.days.from_now
      end

      def create
        @advertisement = Komplex::Advertisement.new(advertisement_params)

        if @advertisement.save
          flash[:success] = t('komplex.admin.advertisements.create.success')
          redirect_to admin_advertisements_path
        else
          flash.now[:error] = t('komplex.admin.advertisements.create.error')
          load_data
          render :new
        end
      end

      def edit
        @advertisement = Komplex::Advertisement.find(params[:id])
      end

      def update
        @advertisement = Komplex::Advertisement.find(params[:id])

        if @advertisement.update(advertisement_params)
          flash[:success] = t('komplex.admin.advertisements.update.success')
          redirect_to admin_advertisements_path
        else
          flash.now[:error] = t('komplex.admin.advertisements.update.error')
          load_data
          render :edit
        end
      end

      def destroy
        @advertisement = Komplex::Advertisement.find(params[:id])

        if @advertisement.destroy
          flash[:success] = t('komplex.admin.advertisements.destroy.success')
        else
          flash[:error] = t('komplex.admin.advertisements.destroy.error')
        end

        redirect_to admin_advertisements_path
      end

      private

      def load_data
        @vendors = Komplex::Vendor.approved
        @listings = Komplex::Listing.published
        @placements = ['homepage', 'search_results', 'category_page', 'listing_detail']
        @ad_types = ['banner', 'sidebar', 'featured', 'popup']
      end

      def model_class
        Komplex::Advertisement
      end

      def advertisement_params
        params.require(:advertisement).permit(
          :title, :description, :placement, :ad_type,
          :vendor_id, :listing_id, :starts_at, :ends_at,
          :cost, :status, :image
        )
      end
    end
  end
end
