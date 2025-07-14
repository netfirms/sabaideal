# Komplex: Multi-Vendor Marketplace Extension for SpreeCommerce

Komplex is a modular, multi-merchant marketplace extension for SpreeCommerce that enables the creation and management of various listing types including properties, restaurants, services, and advertisements. Built as a Rails Engine and Spree extension, Komplex follows the standard Rails MVC (Model-View-Controller) architecture while integrating seamlessly with the Spree Commerce platform.

## Features

- **Multi-vendor marketplace** - Allow vendors to register and manage their marketplace presence
- **Multiple listing types** - Support for property listings, restaurant listings, service listings, and more
- **Advertisements** - Paid vendor ads and campaign placements
- **Commission system** - Configurable commission rates and automated payouts
- **Approval workflows** - For vendors, listings, and reviews
- **Vendor dashboards** - Analytics and management tools for vendors
- **Search and filtering** - Robust search capabilities for listings
- **Messaging system** - Communication between buyers and vendors

## Architecture

### System Overview

Komplex follows the standard Rails MVC (Model-View-Controller) architecture while integrating seamlessly with the Spree Commerce platform. The module is designed as a Rails Engine and Spree extension, allowing it to be easily integrated into any Spree Commerce application.

### Integration with Spree Commerce

Komplex integrates with Spree Commerce by:

1. **Extending Spree Models**
   - Extending `Spree::User` to support merchant capabilities
   - Leveraging `Spree::Product` for listing representation
   - Using `Spree::Order` for marketplace transactions
   - Extending `Spree::Store` for multi-merchant support

2. **Admin Interface Integration**
   - Adding merchant management to Spree Admin
   - Integrating listing approval workflows
   - Adding commission and payout management

3. **Storefront Integration**
   - Enhancing product pages to display listing details
   - Adding merchant profile pages
   - Implementing search and filtering for listings

### Database Structure

Komplex uses a polymorphic association pattern to support multiple listing types:

- **Core Tables**: merchants, listings, categories
- **Listing Type Tables**: properties, restaurants, services
- **Marketing Tables**: advertisements
- **Transaction Tables**: commissions, payouts
- **User Interaction Tables**: reviews, messages, conversations

### API Design

Komplex provides RESTful API endpoints for all resources, including:

- Vendors API
- Listings API
- Properties API
- Restaurants API
- Services API
- Advertisements API
- Commissions API
- Payouts API
- Reviews API
- Search API

### Extensibility

The Komplex module is designed to be extensible in several ways:

1. **New Listing Types**
   - The polymorphic `listable` association allows for easy addition of new listing types
   - Developers can create new listing type models that inherit from a base class

2. **Custom Fields**
   - Each listing type can have custom fields defined through a flexible schema
   - Admin interface allows for configuration of custom fields

3. **Integration Points**
   - Well-defined hooks for extending functionality
   - Event system for reacting to changes in listings, merchants, etc.

4. **Localization**
   - All user-facing text is stored in locale files
   - Support for multiple currencies and measurement units

## Installation

1. Add Komplex to your Gemfile:

```ruby
gem 'komplex'
```

2. Install the gem:

```bash
bundle install
```

3. Run the installer:

```bash
rails g komplex:install
```

4. Run migrations:

```bash
rails db:migrate
```

5. Restart your server:

```bash
rails s
```

## Configuration

Komplex can be configured in an initializer:

```ruby
# config/initializers/komplex.rb
Komplex.configure do |config|
  # Whether vendor approval is required before they can list items
  config.vendor_approval_required = true

  # Whether listing approval is required before they are published
  config.listing_approval_required = true

  # Default commission rate (as a decimal, e.g., 0.10 for 10%)
  config.default_commission_rate = 0.10

  # Whether vendors are allowed to create promotions
  config.allow_vendor_promotions = true

  # Whether vendors are allowed to purchase advertisements
  config.allow_vendor_advertisements = true
end
```

## Usage

### Vendor Registration

Vendors can register through the storefront by visiting `/vendors/new`. The registration form collects basic information about the vendor and their business.

### Listing Management

Vendors can create and manage listings through their dashboard at `/vendors/dashboard`. Listings can be of various types:

- **Property Listings** - For rent and sale, with details like bedrooms, bathrooms, area, etc.
- **Restaurant Listings** - With menus, location, photos, and operational details
- **Service Listings** - For various service categories with pricing models and availability

### Admin Management

Administrators can manage vendors, listings, promotions, and advertisements through the Spree Admin interface. New menu items are added for each of these resources.

## Development

### Testing

To run the test suite:

```bash
bundle exec rspec
```

### Extending Komplex

Komplex is designed to be extensible. You can add new listing types by creating a new model that inherits from `Komplex::Listable` and implementing the required methods.

## License

Komplex is released under the [MIT License](https://opensource.org/licenses/MIT).

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

## Support

For questions or issues, please open an issue on the [GitHub repository](https://github.com/komplex/komplex/issues).
