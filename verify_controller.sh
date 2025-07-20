#!/bin/bash
echo "Verifying that the Komplex::Storefront::ServicesController can be loaded..."
bundle exec rails runner "puts 'Controller test: ' + (defined?(Komplex::Storefront::ServicesController) ? 'Controller loaded successfully!' : 'Controller not found!')"
echo "Controller verification completed."
