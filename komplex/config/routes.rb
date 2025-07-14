# frozen_string_literal: true

Komplex::Engine.routes.draw do
  # Admin routes
  namespace :admin do
    resources :vendors do
      member do
        post :approve
        post :reject
        get :listings
        get :commissions
        get :payouts
        post :create_payout
      end
    end
    resources :listings
    resources :promotions
    resources :advertisements
    resources :payouts
    resources :reviews
  end

  # API routes
  namespace :api do
    namespace :v2 do
      namespace :platform do
        resources :vendors
        resources :listings
        resources :promotions
        resources :advertisements
        resources :payouts
        resources :reviews
        resources :search, only: [:index]
      end
    end
  end

  # Storefront routes
  namespace :storefront do
    resources :vendors
    resources :listings
    get 'vendor/dashboard', to: 'vendors#dashboard', as: :vendor_dashboard
  end
end
