module Komplex
  class Listing < ApplicationRecord
    self.table_name = 'komplex_listings'

    belongs_to :merchant, class_name: 'Komplex::Merchant'
    belongs_to :listable, polymorphic: true
    # has_many :reviews, class_name: 'Komplex::Review', dependent: :destroy
    has_many :advertisements, class_name: 'Komplex::Advertisement', dependent: :nullify

    before_validation :set_default_values

    validates :title, presence: true
    validates :status, presence: true, inclusion: { in: %w[draft pending published rejected] }
    validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :condition, presence: true
    validates :category, presence: true

    scope :published, -> { where(status: 'published') }
    scope :pending, -> { where(status: 'pending') }
    scope :draft, -> { where(status: 'draft') }
    scope :rejected, -> { where(status: 'rejected') }
    scope :featured, -> { where(featured: true) }

    def published?
      status == 'published'
    end

    def pending?
      status == 'pending'
    end

    def draft?
      status == 'draft'
    end

    def rejected?
      status == 'rejected'
    end

    def publish!
      update(status: 'published', published_at: Time.current)
    end

    def reject!
      update(status: 'rejected')
    end

    def submit_for_approval!
      update(status: 'pending')
    end

    def average_rating
      # reviews.approved.average(:rating) || 0
      0 # Return 0 since reviews are not implemented yet
    end

    private

    def set_default_values
      self.condition ||= 'new'

      # Set category based on listable type if available
      if self.category.blank? && self.listable.present?
        case self.listable_type
        when 'Komplex::Restaurant'
          self.category = 'restaurant'
        when 'Komplex::Property', 'Komplex::RealEstateProperty'
          self.category = 'property'
        else
          self.category = 'other'
        end
      end
    end
  end
end
