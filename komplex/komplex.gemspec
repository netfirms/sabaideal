# frozen_string_literal: true

require_relative 'lib/komplex/version'

Gem::Specification.new do |spec|
  spec.name        = 'komplex'
  spec.version     = Komplex::VERSION
  spec.authors     = ['Komplex Team']
  spec.email       = ['info@komplex.io']
  spec.homepage    = 'https://github.com/komplex/komplex'
  spec.summary     = 'Multi-vendor marketplace extension for SpreeCommerce'
  spec.description = 'Komplex is a modular, multi-merchant marketplace extension for SpreeCommerce that enables the creation and management of various listing types including properties, restaurants, services, and advertisements. Built as a Rails Engine and Spree extension, Komplex follows the standard Rails MVC architecture while integrating seamlessly with the Spree Commerce platform.'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/komplex/komplex'
  spec.metadata['changelog_uri'] = 'https://github.com/komplex/komplex/blob/master/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'rails', '~> 8.0.0'
  spec.add_dependency 'spree_core', '>= 4.6.0'
  spec.add_dependency 'spree_api', '>= 4.6.0'
  spec.add_dependency 'spree_admin', '>= 5.0.0'
  spec.add_dependency 'spree_extension'

  spec.add_development_dependency 'spree_dev_tools'
end
