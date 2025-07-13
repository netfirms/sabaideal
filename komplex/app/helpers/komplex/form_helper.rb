module Komplex
  module FormHelper
    def self.included(base)
      base.class_eval do
        # Add field_container method to ActionView::Helpers::FormBuilder
        ActionView::Helpers::FormBuilder.class_eval do
          def field_container(method, options = {}, &block)
            @template.field_container(@object_name, method, options, &block)
          end
        end
      end
    end

    def field_container(object_name, method, options = {}, &block)
      classes = options[:class].to_a
      classes << 'field'
      classes << 'withError' if error_message_on(object_name, method).present?
      content_tag(:div, capture(&block), class: classes.join(' '), id: "#{object_name}_#{method}_field")
    end
  end
end