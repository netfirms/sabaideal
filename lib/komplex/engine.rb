module Komplex
  class Engine < Rails::Engine
    engine_name 'komplex'

    config.autoload_paths += %W(#{config.root}/lib)

    # Add Komplex controllers, models, and views to the load path
    config.eager_load_paths += %W(
      #{config.root}/app/controllers/komplex
      #{config.root}/app/models/komplex
      #{config.root}/app/views/komplex
    )

    initializer 'komplex.environment', before: :load_config_initializers do |app|
      # Load Komplex configuration
      Komplex.configuration = Spree::KomplexConfiguration.new
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
