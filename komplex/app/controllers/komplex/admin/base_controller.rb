# frozen_string_literal: true

module Komplex
  module Admin
    class BaseController < Spree::Admin::ResourceController
      helper Komplex::FormHelper
    end
  end
end
