# frozen_string_literal: true

module Komplex
  module AdminHelper
    def link_to_edit(resource, options = {})
      url = options[:url] || edit_object_url(resource)
      options[:data] = { action: 'edit' }
      link_to_with_icon('edit', url, options)
    end

    def edit_object_url(object, options = {})
      if object.is_a?(Komplex::Vendor)
        edit_admin_vendor_path(object)
      elsif object.is_a?(Komplex::Listing)
        edit_admin_listing_path(object)
      elsif object.is_a?(Komplex::Promotion)
        edit_admin_promotion_path(object)
      elsif object.is_a?(Komplex::Advertisement)
        edit_admin_advertisement_path(object)
      elsif object.is_a?(Komplex::Review)
        edit_admin_review_path(object)
      else
        # Fall back to Spree's behavior if needed
        spree_edit_object_url(object, options)
      end
    end

    private

    def link_to_with_icon(icon_name, url, options = {})
      options[:class] = (options[:class].to_s + " icon-link with-tip action-#{icon_name}").strip
      options[:class] += ' no-text' if options[:no_text]
      options[:title] = options[:no_text] ? Spree.t(icon_name) : options[:title]
      text = options.delete(:no_text) ? '' : options.delete(:title)
      link_to_with_options(url, options) do
        text.blank? ? icon(icon_name) : "#{icon(icon_name)} #{text}".strip
      end
    end

    def link_to_with_options(url, options)
      if options[:no_text]
        link_to '', url, options.except(:no_text)
      else
        link_to yield, url, options.except(:no_text)
      end
    end

    def icon(icon_name, options = {})
      return '' unless icon_name

      css_class = "icon icon-#{icon_name}"
      css_class += " #{options[:class]}" if options[:class].present?

      content_tag(:span, '', class: css_class)
    end

    # If Spree's method exists, use it as a fallback
    def spree_edit_object_url(object, options = {})
      if respond_to?(:edit_object_url, true) && 
         method(:edit_object_url).owner != Komplex::AdminHelper
        super
      else
        # Default fallback if Spree's method doesn't exist
        url_for([:edit, :admin, object])
      end
    end
  end
end
