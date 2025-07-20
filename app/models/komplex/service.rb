module Komplex
  class Service < ApplicationRecord
    self.table_name = 'komplex_services'

    has_one :listing, class_name: 'Komplex::Listing', as: :listable, dependent: :destroy
    accepts_nested_attributes_for :listing

    belongs_to :category, class_name: 'Komplex::Category', optional: true

    validates :pricing_model, presence: true, inclusion: { in: %w(hourly fixed per_session custom) }

    # Optional fields
    # duration_minutes - integer
    # service_area - text
    # remote_available - boolean
  end
end
