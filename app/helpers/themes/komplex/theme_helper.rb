module Themes
  module Komplex
    module ThemeHelper
      def body_class
        [controller_name, action_name].join(' ')
      end
    end
  end
end