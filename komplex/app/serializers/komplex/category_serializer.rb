# frozen_string_literal: true

module Komplex
  class CategorySerializer < Spree::BaseSerializer
    set_type :category

    attributes :name, :description, :icon, :position, :created_at, :updated_at

    attribute :has_parent do |category|
      category.parent.present?
    end

    attribute :has_children do |category|
      category.children.exists?
    end

    attribute :children_count do |category|
      category.children.count
    end

    belongs_to :parent, serializer: :category, optional: true
    has_many :children, serializer: :category, record_type: :category
  end
end