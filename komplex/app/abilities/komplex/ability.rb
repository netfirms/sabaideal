# frozen_string_literal: true

module Komplex
  class Ability
    include CanCan::Ability

    def initialize(user)
      # Anonymous users can view published listings
      can :read, Komplex::Listing, status: 'published'
      can :read, Komplex::Vendor, status: 'approved'
      can :read, Komplex::Review, approved: true

      return unless user

      # Authenticated users
      can :create, Komplex::Vendor
      can :create, Komplex::Review
      can :create, Komplex::Conversation
      can :create, Komplex::Message

      # Users can manage their own conversations and messages
      can :manage, Komplex::Conversation, buyer_id: user.id
      can :manage, Komplex::Message, sender_id: user.id

      # Vendor capabilities
      if user.vendor?
        vendor = user.vendor
        
        # Vendors can manage their own listings
        can :manage, Komplex::Listing, vendor_id: vendor.id
        
        # Vendors can manage their vendor profile
        can :manage, Komplex::Vendor, id: vendor.id
        
        # Vendors can manage conversations related to their listings
        can :manage, Komplex::Conversation, vendor_id: vendor.id
        
        # Vendors can create promotions if allowed
        if Komplex.configuration.allow_vendor_promotions
          can :manage, Komplex::Promotion, vendor_id: vendor.id
        end
        
        # Vendors can create advertisements if allowed
        if Komplex.configuration.allow_vendor_advertisements
          can :manage, Komplex::Advertisement, vendor_id: vendor.id
        end
        
        # Vendors can view their commissions and payouts
        can :read, Komplex::Commission, vendor_id: vendor.id
        can :read, Komplex::Payout, vendor_id: vendor.id
      end

      # Admin capabilities
      if user.respond_to?(:has_spree_role?) && user.has_spree_role?('admin')
        # Admins can manage everything
        can :manage, :all
      end
    end
  end
end