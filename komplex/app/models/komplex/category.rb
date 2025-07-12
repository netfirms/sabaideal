# frozen_string_literal: true

module Komplex
  class Category < ApplicationRecord
    has_many :services, dependent: :nullify
    has_many :children, class_name: 'Komplex::Category', foreign_key: 'parent_id', dependent: :nullify
    belongs_to :parent, class_name: 'Komplex::Category', optional: true

    validates :name, presence: true, uniqueness: true

    scope :roots, -> { where(parent_id: nil) }
    scope :sorted, -> { order(position: :asc) }

    def root?
      parent_id.nil?
    end

    def leaf?
      children.empty?
    end

    def ancestors
      return [] if root?

      parent.ancestors + [parent]
    end

    def self_and_ancestors
      ancestors + [self]
    end

    def descendants
      children.flat_map { |child| [child] + child.descendants }
    end

    def self_and_descendants
      [self] + descendants
    end
  end
end