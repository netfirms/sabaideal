module Komplex
  module Admin
    module ListingsHelper
      include Komplex::Admin::BaseHelper

      def status_badge_class(status)
        case status.to_s
        when 'draft'
          'badge-draft'
        when 'pending'
          'badge-pending'
        when 'published'
          'badge-published'
        when 'rejected'
          'badge-rejected'
        else
          'badge-secondary'
        end
      end
    end
  end
end
