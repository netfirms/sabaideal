module Komplex
  class Restaurant < ApplicationRecord
    self.table_name = 'komplex_restaurants'

    has_one :listing, class_name: 'Komplex::Listing', as: :listable, dependent: :destroy
    accepts_nested_attributes_for :listing

    serialize :menu_items, coder: YAML
    serialize :opening_hours, coder: YAML

    validates :cuisine_type, presence: true
    validates :opening_hours, presence: true
    validates :address, presence: true
  end
end
