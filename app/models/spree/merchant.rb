module Spree
  class Merchant < Komplex::Merchant
    # This class inherits from Komplex::Merchant to provide compatibility
    # when the model is accessed through the Spree namespace
  end
end