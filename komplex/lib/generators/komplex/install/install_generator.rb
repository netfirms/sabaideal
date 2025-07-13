# frozen_string_literal: true

module Komplex
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      class_option :auto_run_migrations, type: :boolean, default: false

      # Skip JavaScript and CSS files as they don't exist
      def add_assets
        # No JavaScript or CSS files to add
      end

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=komplex'
      end

      def mount_engine
        route "mount Komplex::Engine, at: '/'"
      end

      def create_initializer
        template 'initializer.rb', 'config/initializers/komplex.rb'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]'))
        if run_migrations
          run 'bundle exec rake db:migrate'
        else
          puts 'Skipping rake db:migrate, don\'t forget to run it!'
        end
      end
    end
  end
end
