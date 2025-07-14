# frozen_string_literal: true

module Komplex
  module VendorDecorator
    def self.prepended(base)
      base.has_one :store, class_name: 'Spree::Store', dependent: :nullify
      base.after_create :create_store
      base.after_update :update_store, if: -> { saved_change_to_name? || saved_change_to_description? }
    end

    def ensure_store_exists
      create_store if store.nil?
    end

    private

    def create_store
      self.store = Spree::Store.create(
        name: name,
        url: generate_store_url,
        mail_from_address: user.email,
        default_currency: 'USD',
        supported_currencies: 'USD',
        default_locale: 'en',
        supported_locales: 'en',
        meta_description: description.to_s.truncate(160),
        meta_keywords: generate_meta_keywords,
        seo_title: name
      )
    end

    def update_store
      return unless store

      store.update(
        name: name,
        url: generate_store_url,
        meta_description: description.to_s.truncate(160),
        meta_keywords: generate_meta_keywords,
        seo_title: name
      )
    end

    def generate_store_url
      # Create a URL-friendly version of the vendor name
      # Handle nil or empty name gracefully
      base_url = if name.present?
                   name.parameterize
                 else
                   "vendor-#{id || Time.current.to_i}"
                 end

      # Check if the URL already exists
      existing_urls = Spree::Store.where.not(id: store&.id).pluck(:url)

      if existing_urls.include?(base_url)
        # Append a number to make it unique
        counter = 1
        while existing_urls.include?("#{base_url}-#{counter}")
          counter += 1
        end
        "#{base_url}-#{counter}"
      else
        base_url
      end
    end

    def generate_meta_keywords
      # Generate meta keywords based on vendor name and description
      keywords = []

      # Add name to keywords if present
      keywords << name if name.present?

      # Add some keywords based on the description
      if description.present?
        # Extract potential keywords from description
        words = description.downcase.split(/\W+/).uniq
        # Filter out common words and short words
        filtered_words = words.reject { |w| w.length < 4 || common_words.include?(w) }
        # Take up to 5 keywords from description
        keywords += filtered_words.first(5)
      end

      # Return default keyword if no keywords were generated
      keywords.present? ? keywords.join(', ') : 'vendor'
    end

    def common_words
      %w[this that with have from will would there their they them then about because been]
    end
  end
end

Komplex::Vendor.prepend Komplex::VendorDecorator if defined?(Komplex::Vendor)
