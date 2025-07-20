module Komplex
  class Category < ApplicationRecord
    self.table_name = 'komplex_categories'

    belongs_to :parent, class_name: 'Komplex::Category', optional: true
    has_many :subcategories, class_name: 'Komplex::Category', foreign_key: 'parent_id', dependent: :destroy

    validates :name, presence: true, uniqueness: true

    scope :root_categories, -> { where(parent_id: nil) }
    scope :ordered, -> { order(position: :asc) }

    def root?
      parent_id.nil?
    end

    def leaf?
      subcategories.empty?
    end

    def ancestors
      return [] if root?

      parent.ancestors + [parent]
    end

    def self_and_ancestors
      ancestors + [self]
    end

    def descendants
      subcategories.flat_map { |subcategory| [subcategory] + subcategory.descendants }
    end

    def self_and_descendants
      [self] + descendants
    end
  end
end
