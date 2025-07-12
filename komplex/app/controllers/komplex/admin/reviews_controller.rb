# frozen_string_literal: true

module Komplex
  module Admin
    class ReviewsController < Spree::Admin::ResourceController
      before_action :load_data, except: [:index, :destroy]

      def index
        @reviews = Komplex::Review.all
        
        # Apply filters
        @reviews = @reviews.by_listing(params[:listing_id]) if params[:listing_id].present?
        @reviews = @reviews.by_user(params[:user_id]) if params[:user_id].present?
        @reviews = @reviews.where(approved: params[:approved]) if params[:approved].present?
        @reviews = @reviews.where('rating >= ?', params[:min_rating]) if params[:min_rating].present?
        @reviews = @reviews.where('rating <= ?', params[:max_rating]) if params[:max_rating].present?
        
        # Apply sorting
        case params[:sort]
        when 'newest'
          @reviews = @reviews.order(created_at: :desc)
        when 'oldest'
          @reviews = @reviews.order(created_at: :asc)
        when 'highest_rated'
          @reviews = @reviews.highest_rated
        when 'lowest_rated'
          @reviews = @reviews.lowest_rated
        else
          @reviews = @reviews.order(created_at: :desc)
        end
        
        @reviews = @reviews.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def approve
        @review = Komplex::Review.find(params[:id])
        if @review.approve!
          flash[:success] = t('komplex.admin.reviews.approve.success')
          Komplex::ApprovalNotificationWorker.perform_async('Komplex::Review', @review.id, 'approved')
        else
          flash[:error] = t('komplex.admin.reviews.approve.error')
        end
        redirect_to admin_reviews_path
      end

      def reject
        @review = Komplex::Review.find(params[:id])
        if @review.reject!
          flash[:success] = t('komplex.admin.reviews.reject.success')
          Komplex::ApprovalNotificationWorker.perform_async('Komplex::Review', @review.id, 'rejected')
        else
          flash[:error] = t('komplex.admin.reviews.reject.error')
        end
        redirect_to admin_reviews_path
      end

      def edit
        @review = Komplex::Review.find(params[:id])
      end

      def update
        @review = Komplex::Review.find(params[:id])
        
        if @review.update(review_params)
          flash[:success] = t('komplex.admin.reviews.update.success')
          redirect_to admin_reviews_path
        else
          flash.now[:error] = t('komplex.admin.reviews.update.error')
          load_data
          render :edit
        end
      end

      def destroy
        @review = Komplex::Review.find(params[:id])
        
        if @review.destroy
          flash[:success] = t('komplex.admin.reviews.destroy.success')
        else
          flash[:error] = t('komplex.admin.reviews.destroy.error')
        end
        
        redirect_to admin_reviews_path
      end

      private

      def load_data
        @listings = Komplex::Listing.published
        @users = Spree::User.all
      end

      def model_class
        Komplex::Review
      end

      def review_params
        params.require(:review).permit(
          :rating, :comment, :approved
        )
      end
    end
  end
end