# Komplex

Komplex is a modular, multi-vendor marketplace extension for SpreeCommerce that enables the creation and management of various listing types including properties, restaurants, services, promotions, and advertisements.

## Features

- **Multi-vendor marketplace** - Allow vendors to register and manage their marketplace presence
- **Multiple listing types** - Support for property listings, restaurant listings, service listings, and more
- **Promotions** - Vendor-level and platform-wide promotions
- **Advertisements** - Paid vendor ads and campaign placements
- **Commission system** - Configurable commission rates and automated payouts
- **Approval workflows** - For vendors, listings, and reviews
- **Vendor dashboards** - Analytics and management tools for vendors

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