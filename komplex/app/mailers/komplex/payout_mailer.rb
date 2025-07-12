# frozen_string_literal: true

module Komplex
  class PayoutMailer < ApplicationMailer
    def processing_notification(payout)
      @payout = payout
      @vendor = payout.vendor
      @user = @vendor.user
      @amount = payout.amount
      @commissions_count = Komplex::Commission.where(vendor_id: @vendor.id, status: 'paid', paid_at: @payout.created_at).count

      mail(
        to: @user.email,
        subject: I18n.t('komplex.payout_mailer.processing_notification.subject', amount: format_currency(@amount))
      )
    end

    def completion_notification(payout)
      @payout = payout
      @vendor = payout.vendor
      @user = @vendor.user
      @amount = payout.amount
      @transaction_id = payout.transaction_id
      @processed_at = payout.processed_at

      mail(
        to: @user.email,
        subject: I18n.t('komplex.payout_mailer.completion_notification.subject', amount: format_currency(@amount))
      )
    end

    def failure_notification(payout)
      @payout = payout
      @vendor = payout.vendor
      @user = @vendor.user
      @amount = payout.amount
      @failure_reason = payout.notes
      @admin_email = Spree::Store.default.mail_from_address

      # Send to vendor
      mail(
        to: @user.email,
        subject: I18n.t('komplex.payout_mailer.failure_notification.subject', amount: format_currency(@amount))
      )
    end

    def admin_failure_notification(payout)
      @payout = payout
      @vendor = payout.vendor
      @user = @vendor.user
      @amount = payout.amount
      @failure_reason = payout.notes
      @admin_email = Spree::Store.default.mail_from_address

      # Send to admin
      mail(
        to: @admin_email,
        subject: I18n.t('komplex.payout_mailer.admin_failure_notification.subject', 
                        vendor: @vendor.name, 
                        amount: format_currency(@amount))
      )
    end

    def monthly_summary(vendor, month, year)
      @vendor = vendor
      @user = vendor.user
      @month = month
      @year = year
      
      # Get date range for the month
      start_date = Date.new(year, month, 1)
      end_date = start_date.end_of_month
      
      # Get payouts for the month
      @payouts = Komplex::Payout.where(vendor_id: vendor.id, created_at: start_date..end_date)
      @total_amount = @payouts.sum(:amount)
      @completed_amount = @payouts.where(status: 'completed').sum(:amount)
      @pending_amount = @payouts.where(status: ['pending', 'processing']).sum(:amount)
      @failed_amount = @payouts.where(status: 'failed').sum(:amount)
      
      # Get commissions for the month
      @commissions = Komplex::Commission.where(vendor_id: vendor.id, created_at: start_date..end_date)
      @total_commission_amount = @commissions.sum(:vendor_amount)
      
      mail(
        to: @user.email,
        subject: I18n.t('komplex.payout_mailer.monthly_summary.subject', 
                        month: I18n.l(start_date, format: '%B'), 
                        year: year)
      )
    end

    private

    def format_currency(amount)
      ActionController::Base.helpers.number_to_currency(amount)
    end
  end
end