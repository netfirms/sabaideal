# frozen_string_literal: true

module Komplex
  module Admin
    class PromotionsController < Spree::Admin::ResourceController
      before_action :load_data, except: [:index, :destroy]

      def index
        @promotions = Komplex::Promotion.all
        
        # Apply filters
        @promotions = @promotions.by_vendor(params[:vendor_id]) if params[:vendor_id].present?
        @promotions = @promotions.platform_wide if params[:platform_wide] == 'true'
        
        # Apply date filters
        if params[:active] == 'true'
          @promotions = @promotions.active
        elsif params[:expired] == 'true'
          @promotions = @promotions.expired
        elsif params[:upcoming] == 'true'
          @promotions = @promotions.upcoming
        end
        
        # Apply sorting
        case params[:sort]
        when 'newest'
          @promotions = @promotions.order(created_at: :desc)
        when 'oldest'
          @promotions = @promotions.order(created_at: :asc)
        when 'starts_soon'
          @promotions = @promotions.order(starts_at: :asc)
        when 'ends_soon'
          @promotions = @promotions.order(ends_at: :asc)
        else
          @promotions = @promotions.order(created_at: :desc)
        end
        
        @promotions = @promotions.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def new
        @promotion = Komplex::Promotion.new
        @promotion.starts_at = Time.current
        @promotion.ends_at = 30.days.from_now
      end

      def create
        @promotion = Komplex::Promotion.new(promotion_params)
        
        if @promotion.save
          flash[:success] = t('komplex.admin.promotions.create.success')
          redirect_to admin_promotions_path
        else
          flash.now[:error] = t('komplex.admin.promotions.create.error')
          load_data
          render :new
        end
      end

      def edit
        @promotion = Komplex::Promotion.find(params[:id])
      end

      def update
        @promotion = Komplex::Promotion.find(params[:id])
        
        if @promotion.update(promotion_params)
          flash[:success] = t('komplex.admin.promotions.update.success')
          redirect_to admin_promotions_path
        else
          flash.now[:error] = t('komplex.admin.promotions.update.error')
          load_data
          render :edit
        end
      end

      def destroy
        @promotion = Komplex::Promotion.find(params[:id])
        
        if @promotion.destroy
          flash[:success] = t('komplex.admin.promotions.destroy.success')
        else
          flash[:error] = t('komplex.admin.promotions.destroy.error')
        end
        
        redirect_to admin_promotions_path
      end

      private

      def load_data
        @vendors = Komplex::Vendor.approved
        @listings = Komplex::Listing.published
      end

      def model_class
        Komplex::Promotion
      end

      def promotion_params
        params.require(:promotion).permit(
          :title, :description, :promotion_type, :discount_amount,
          :starts_at, :ends_at, :vendor_id, :listing_id, :code,
          :usage_limit
        )
      end
    end
  end
end