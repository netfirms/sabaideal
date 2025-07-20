module Spree
  class Restaurant < Komplex::Restaurant
    # This class inherits from Komplex::Restaurant to ensure compatibility
    # when accessed through the Spree::Admin namespace
  end
end