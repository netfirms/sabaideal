module Komplex
  class Conversation < ApplicationRecord
    self.table_name = 'komplex_conversations'

    belongs_to :listing, class_name: 'Komplex::Listing'
    belongs_to :buyer, class_name: 'Spree::User'
    belongs_to :merchant, class_name: 'Komplex::Merchant'
    has_many :messages, class_name: 'Komplex::Message', dependent: :destroy

    validates :status, presence: true, inclusion: { in: %w[active archived] }

    scope :active, -> { where(status: 'active') }
    scope :archived, -> { where(status: 'archived') }

    def active?
      status == 'active'
    end

    def archived?
      status == 'archived'
    end

    def archive!
      update(status: 'archived')
    end

    def activate!
      update(status: 'active')
    end

    def unread_messages_for(user)
      if user.is_a?(Spree::User) && user.id == buyer_id
        messages.where(read: false).where.not(sender_id: buyer_id)
      elsif user.is_a?(Komplex::Merchant) && user.id == merchant_id
        messages.where(read: false).where.not(sender_id: merchant.user_id)
      else
        messages.none
      end
    end
  end
end