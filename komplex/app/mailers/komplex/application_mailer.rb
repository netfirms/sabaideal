# frozen_string_literal: true

module Komplex
  class ApplicationMailer < ActionMailer::Base
    default from: -> { Spree::Store.default.mail_from_address }
    layout 'mailer'

    helper Spree::BaseHelper
    helper Spree::StoreHelper

    before_action :set_store
    before_action :set_logo

    private

    def set_store
      @store = Spree::Store.default
    end

    def set_logo
      @logo_url = @store.logo&.attachment&.url || ActionController::Base.helpers.asset_path('logo/komplex_logo.png')
    end
  end
end