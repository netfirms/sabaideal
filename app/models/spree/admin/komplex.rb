module Spree
  module Admin
    module Komplex
      def self.const_missing(const_name)
        ::Komplex.const_get(const_name)
      end
    end
  end
end