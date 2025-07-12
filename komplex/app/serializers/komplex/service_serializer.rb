# frozen_string_literal: true

module Komplex
  class ServiceSerializer < Spree::BaseSerializer
    set_type :service

    attributes :pricing_model, :price, :duration_minutes, :service_area, 
               :remote_available, :created_at, :updated_at

    attribute :duration_formatted do |service|
      if service.duration_minutes
        hours = service.duration_minutes / 60
        minutes = service.duration_minutes % 60
        
        if hours > 0
          "#{hours} hour#{'s' if hours > 1}#{' and ' if minutes > 0}#{minutes > 0 ? "#{minutes} minute#{'s' if minutes > 1}" : ''}"
        else
          "#{minutes} minute#{'s' if minutes > 1}"
        end
      end
    end

    belongs_to :listing, serializer: :listing
    belongs_to :category, serializer: :category
  end
end