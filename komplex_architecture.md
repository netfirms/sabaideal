# Komplex: Multi-Vendor Marketplace Extension for SpreeCommerce

## High-Level Architecture

### System Overview

Komplex is a modular, multi-merchant marketplace extension for SpreeCommerce that enables the creation and management of various listing types including properties, restaurants, services, and advertisements. Built as a Rails Engine and Spree extension, Komplex follows the standard Rails MVC (Model-View-Controller) architecture while integrating seamlessly with the Spree Commerce platform.

**Core Module Goals:**
- Enable vendors to register and manage their marketplace presence
- Support multiple listing types (properties, restaurants, services, etc.)
- Provide robust search and filtering capabilities
- Implement commission and payout logic for marketplace transactions
- Support approval workflows for listings and vendors
- Enable platform-wide and vendor-specific promotions and advertisements

### Component Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Komplex Marketplace                           │
├─────────────┬─────────────┬──────────────────────────────────────────┤
│             │             │                                          │
│  Merchant   │  Listing    │  Advertisement                           │
│  Management │  Management │  Management                              │
│             │             │                                          │
├─────────────┼─────────────┼──────────────────────────────────────────┤
│             │             │                                          │
│  Property   │  Restaurant │  Service                                 │
│  Listings   │  Listings   │  Listings                                │
│             │             │                                          │
├─────────────┴─────────────┴──────────────────────────────────────────┤
│                                                                      │
│                      Spree Commerce Integration                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │
│  │ User &       │  │ Product &    │  │ Order &      │               │
│  │ Store        │  │ Variant      │  │ Payment      │               │
│  └──────────────┘  └──────────────┘  └──────────────┘               │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### User Roles and Permissions

1. **Buyer**
   - Browse and search listings
   - Contact merchants
   - Make purchases and bookings
   - Submit reviews and ratings
   - View transaction history

2. **Merchant**
   - Create and manage listings
   - Manage merchant profile and settings
   - Receive and respond to inquiries
   - View analytics for their listings
   - Purchase advertisement placements

3. **Administrator**
   - Approve/reject merchants and listings
   - Configure commission rates
   - Access comprehensive analytics
   - Manage advertisement placements
   - Configure system settings

### Data Flow Diagram

```
┌──────────────┐     ┌───────────────┐     ┌───────────────┐
│              │     │               │     │               │
│  Merchant    │────▶│  Listing      │◀────│  Buyer        │
│  Registration│     │  Management   │     │  Browsing     │
│              │     │               │     │               │
└──────────────┘     └───────┬───────┘     └──────────────┘
                             │
                             ▼
┌──────────────┐     ┌───────────────┐     ┌───────────────┐
│              │     │               │     │               │
│  Admin       │◀────│  Approval     │────▶│  Notification │
│  Review      │     │  Workflow     │     │  System       │
│              │     │               │     │               │
└──────┬───────┘     └───────┬───────┘     └───────────────┘
       │                     │
       ▼                     ▼
┌──────────────┐     ┌───────────────┐     ┌───────────────┐
│              │     │               │     │               │
│ Advertisement│────▶│  Marketplace  │────▶│  Commission   │
│  Management  │     │  Transactions │     │  Processing   │
│              │     │               │     │               │
└──────────────┘     └───────────────┘     └───────────────┘
```

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

## Low-Level Architecture

### Entity-Relationship Diagram (ERD)

```
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│ spree_users   │       │ komplex_      │       │ komplex_      │
├───────────────┤       │ merchants     │       │ listings      │
│ id            │       ├───────────────┤       ├───────────────┤
│ email         │◀──┐   │ id            │       │ id            │
│ encrypted_pass│   │   │ user_id       │────┐  │ title         │
│ ...           │   │   │ name          │    │  │ description   │
└───────────────┘   │   │ description   │    │  │ price         │
                    │   │ status        │    │  │ listable_id   │◀──────┐
                    │   │ commission_rate│    │  │ listable_type│       │
                    │   │ ...           │    │  │ merchant_id   │────┘  │
                    │   └───────────────┘    │  │ status        │       │
                    │                        │  │ ...           │       │
                    │                        │  └───────────────┘       │
                    │                        │                          │
                    │   ┌───────────────┐    │  ┌───────────────┐       │
                    │   │ komplex_      │    │  │ komplex_      │       │
                    │   │ commissions   │    │  │ properties    │       │
                    │   ├───────────────┤    │  ├───────────────┤       │
                    │   │ id            │    │  │ id            │       │
                    └───│ user_id       │    │  │ listing_id    │───────┘
                        │ merchant_id   │◀───┘  │ property_type │
                        │ order_id      │       │ bedrooms      │
                        │ amount        │       │ bathrooms     │
                        │ status        │       │ area          │
                        │ ...           │       │ address       │
                        └───────────────┘       │ ...           │
                                                └───────────────┘

┌───────────────┐       ┌───────────────┐
│ komplex_      │       │ komplex_      │
│ restaurants   │       │ services      │
├───────────────┤       ├───────────────┤
│ id            │       │ id            │
│ listing_id    │───────│ listing_id    │
│ cuisine_type  │       │ category_id   │
│ menu_items    │       │ pricing_model │
│ opening_hours │       │ duration      │
│ ...           │       │ ...           │
└───────────────┘       └───────────────┘

┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│ komplex_      │       │ komplex_      │       │ komplex_      │
│ advertisements│       │ reviews       │       │ categories    │
├───────────────┤       ├───────────────┤       ├───────────────┤
│ id            │       │ id            │       │ id            │
│ title         │       │ listing_id    │       │ name          │
│ description   │       │ user_id       │       │ description   │
│ image         │       │ rating        │       │ parent_id     │
│ url           │       │ comment       │       │ ...           │
│ starts_at     │       │ status        │       └───────────────┘
│ ends_at       │       │ ...           │
│ merchant_id   │       └───────────────┘
│ ...           │
└───────────────┘
```

### Database Schema Design

#### Core Tables

1. **komplex_merchants**
   ```ruby
   create_table "komplex_merchants", force: :cascade do |t|
     t.references "user", null: false, foreign_key: { to_table: "spree_users" }
     t.string "name", null: false
     t.text "description"
     t.string "status", default: "pending", null: false  # pending, approved, rejected
     t.decimal "commission_rate", precision: 5, scale: 2, default: "0.0"
     t.jsonb "settings", default: {}
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["status"], name: "index_komplex_merchants_on_status"
   end
   ```

2. **komplex_listings**
   ```ruby
   create_table "komplex_listings", force: :cascade do |t|
     t.string "title", null: false
     t.text "description"
     t.decimal "price", precision: 10, scale: 2
     t.references "merchant", null: false, foreign_key: { to_table: "komplex_merchants" }
     t.references "listable", polymorphic: true, null: false
     t.string "status", default: "draft", null: false  # draft, pending, published, rejected
     t.boolean "featured", default: false
     t.datetime "published_at"
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["status"], name: "index_komplex_listings_on_status"
     t.index ["featured"], name: "index_komplex_listings_on_featured"
   end
   ```

3. **komplex_categories**
   ```ruby
   create_table "komplex_categories", force: :cascade do |t|
     t.string "name", null: false
     t.text "description"
     t.string "icon"
     t.references "parent", foreign_key: { to_table: "komplex_categories" }
     t.integer "position", default: 0
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["name"], name: "index_komplex_categories_on_name", unique: true
   end
   ```

#### Listing Type Tables

1. **komplex_properties**
   ```ruby
   create_table "komplex_properties", force: :cascade do |t|
     t.references "listing", null: false, foreign_key: { to_table: "komplex_listings" }
     t.string "property_type", null: false  # apartment, house, condo, etc.
     t.string "listing_type", null: false   # rent, sale
     t.integer "bedrooms"
     t.integer "bathrooms"
     t.decimal "area", precision: 10, scale: 2
     t.string "area_unit", default: "sqm"   # sqm, sqft
     t.string "address", null: false
     t.string "city", null: false
     t.string "state"
     t.string "postal_code"
     t.string "country", null: false
     t.decimal "latitude", precision: 10, scale: 6
     t.decimal "longitude", precision: 10, scale: 6
     t.boolean "furnished", default: false
     t.date "available_from"
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["property_type"], name: "index_komplex_properties_on_property_type"
     t.index ["listing_type"], name: "index_komplex_properties_on_listing_type"
     t.index ["bedrooms"], name: "index_komplex_properties_on_bedrooms"
     t.index ["bathrooms"], name: "index_komplex_properties_on_bathrooms"
     t.index ["city"], name: "index_komplex_properties_on_city"
     t.index ["latitude", "longitude"], name: "index_komplex_properties_on_coordinates"
   end
   ```

2. **komplex_restaurants**
   ```ruby
   create_table "komplex_restaurants", force: :cascade do |t|
     t.references "listing", null: false, foreign_key: { to_table: "komplex_listings" }
     t.string "cuisine_type"
     t.jsonb "menu_items", default: []
     t.jsonb "opening_hours", default: {}
     t.string "address", null: false
     t.string "city", null: false
     t.string "state"
     t.string "postal_code"
     t.string "country", null: false
     t.decimal "latitude", precision: 10, scale: 6
     t.decimal "longitude", precision: 10, scale: 6
     t.boolean "delivery_available", default: false
     t.boolean "takeout_available", default: false
     t.boolean "reservation_required", default: false
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["cuisine_type"], name: "index_komplex_restaurants_on_cuisine_type"
     t.index ["city"], name: "index_komplex_restaurants_on_city"
     t.index ["latitude", "longitude"], name: "index_komplex_restaurants_on_coordinates"
   end
   ```

3. **komplex_services**
   ```ruby
   create_table "komplex_services", force: :cascade do |t|
     t.references "listing", null: false, foreign_key: { to_table: "komplex_listings" }
     t.references "category", null: false, foreign_key: { to_table: "komplex_categories" }
     t.string "pricing_model", null: false  # hourly, fixed, etc.
     t.decimal "price", precision: 10, scale: 2
     t.integer "duration_minutes"
     t.text "service_area"
     t.boolean "remote_available", default: false
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["pricing_model"], name: "index_komplex_services_on_pricing_model"
     t.index ["category_id"], name: "index_komplex_services_on_category_id"
   end
   ```

#### Marketing Tables

1. **komplex_advertisements**
   ```ruby
   create_table "komplex_advertisements", force: :cascade do |t|
     t.string "title", null: false
     t.text "description"
     t.string "placement", null: false  # homepage, search_results, category_page
     t.string "ad_type", null: false    # banner, sidebar, featured
     t.references "merchant", null: false, foreign_key: { to_table: "komplex_merchants" }
     t.references "listing", foreign_key: { to_table: "komplex_listings" }
     t.datetime "starts_at", null: false
     t.datetime "ends_at", null: false
     t.decimal "cost", precision: 10, scale: 2, null: false
     t.string "status", default: "pending"  # pending, active, completed, rejected
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["placement"], name: "index_komplex_advertisements_on_placement"
     t.index ["ad_type"], name: "index_komplex_advertisements_on_ad_type"
     t.index ["status"], name: "index_komplex_advertisements_on_status"
     t.index ["starts_at", "ends_at"], name: "index_komplex_advertisements_on_date_range"
   end
   ```

#### Transaction Tables

1. **komplex_commissions**
   ```ruby
   create_table "komplex_commissions", force: :cascade do |t|
     t.references "merchant", null: false, foreign_key: { to_table: "komplex_merchants" }
     t.references "order", null: false, foreign_key: { to_table: "spree_orders" }
     t.references "line_item", foreign_key: { to_table: "spree_line_items" }
     t.decimal "merchant_amount", precision: 10, scale: 2, null: false
     t.decimal "commission_amount", precision: 10, scale: 2, null: false
     t.string "status", default: "pending"  # pending, paid, failed
     t.datetime "paid_at"
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["status"], name: "index_komplex_commissions_on_status"
   end
   ```

2. **komplex_payouts**
   ```ruby
   create_table "komplex_payouts", force: :cascade do |t|
     t.references "merchant", null: false, foreign_key: { to_table: "komplex_merchants" }
     t.decimal "amount", precision: 10, scale: 2, null: false
     t.string "status", default: "pending"  # pending, processing, completed, failed
     t.string "transaction_id"
     t.text "notes"
     t.datetime "processed_at"
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["status"], name: "index_komplex_payouts_on_status"
   end
   ```

#### User Interaction Tables

1. **komplex_reviews**
   ```ruby
   create_table "komplex_reviews", force: :cascade do |t|
     t.references "listing", null: false, foreign_key: { to_table: "komplex_listings" }
     t.references "user", null: false, foreign_key: { to_table: "spree_users" }
     t.integer "rating", null: false
     t.text "comment"
     t.boolean "approved", default: false
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["approved"], name: "index_komplex_reviews_on_approved"
   end
   ```

2. **komplex_messages**
   ```ruby
   create_table "komplex_messages", force: :cascade do |t|
     t.references "conversation", null: false, foreign_key: { to_table: "komplex_conversations" }
     t.references "sender", null: false, foreign_key: { to_table: "spree_users" }
     t.text "content", null: false
     t.boolean "read", default: false
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
   end
   ```

3. **komplex_conversations**
   ```ruby
   create_table "komplex_conversations", force: :cascade do |t|
     t.references "listing", null: false, foreign_key: { to_table: "komplex_listings" }
     t.references "buyer", null: false, foreign_key: { to_table: "spree_users" }
     t.references "vendor", null: false, foreign_key: { to_table: "komplex_vendors" }
     t.string "status", default: "active"  # active, archived
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["status"], name: "index_komplex_conversations_on_status"
   end
   ```

### API Design

#### RESTful API Endpoints

1. **Vendors API**
   ```
   GET    /api/v2/platform/komplex/vendors                # List all vendors
   GET    /api/v2/platform/komplex/vendors/:id            # Get a specific vendor
   POST   /api/v2/platform/komplex/vendors                # Create a new vendor
   PUT    /api/v2/platform/komplex/vendors/:id            # Update a vendor
   DELETE /api/v2/platform/komplex/vendors/:id            # Delete a vendor
   PUT    /api/v2/platform/komplex/vendors/:id/approve    # Approve a vendor
   PUT    /api/v2/platform/komplex/vendors/:id/reject     # Reject a vendor
   ```

2. **Listings API**
   ```
   GET    /api/v2/platform/komplex/listings               # List all listings
   GET    /api/v2/platform/komplex/listings/:id           # Get a specific listing
   POST   /api/v2/platform/komplex/listings               # Create a new listing
   PUT    /api/v2/platform/komplex/listings/:id           # Update a listing
   DELETE /api/v2/platform/komplex/listings/:id           # Delete a listing
   PUT    /api/v2/platform/komplex/listings/:id/approve   # Approve a listing
   PUT    /api/v2/platform/komplex/listings/:id/reject    # Reject a listing
   ```

3. **Properties API**
   ```
   GET    /api/v2/platform/komplex/properties             # List all properties
   GET    /api/v2/platform/komplex/properties/:id         # Get a specific property
   ```

4. **Restaurants API**
   ```
   GET    /api/v2/platform/komplex/restaurants            # List all restaurants
   GET    /api/v2/platform/komplex/restaurants/:id        # Get a specific restaurant
   ```

5. **Services API**
   ```
   GET    /api/v2/platform/komplex/services               # List all services
   GET    /api/v2/platform/komplex/services/:id           # Get a specific service
   ```


6. **Advertisements API**
   ```
   GET    /api/v2/platform/komplex/advertisements         # List all advertisements
   GET    /api/v2/platform/komplex/advertisements/:id     # Get a specific advertisement
   POST   /api/v2/platform/komplex/advertisements         # Create a new advertisement
   PUT    /api/v2/platform/komplex/advertisements/:id     # Update an advertisement
   DELETE /api/v2/platform/komplex/advertisements/:id     # Delete an advertisement
   ```

7. **Commissions API**
   ```
   GET    /api/v2/platform/komplex/commissions            # List all commissions
   GET    /api/v2/platform/komplex/commissions/:id        # Get a specific commission
   PUT    /api/v2/platform/komplex/commissions/:id/pay    # Mark a commission as paid
   ```

8. **Payouts API**
   ```
   GET    /api/v2/platform/komplex/payouts                # List all payouts
   GET    /api/v2/platform/komplex/payouts/:id            # Get a specific payout
   POST   /api/v2/platform/komplex/payouts                # Create a new payout
   PUT    /api/v2/platform/komplex/payouts/:id            # Update a payout
   ```

9. **Reviews API**
    ```
    GET    /api/v2/platform/komplex/reviews               # List all reviews
    GET    /api/v2/platform/komplex/reviews/:id           # Get a specific review
    POST   /api/v2/platform/komplex/reviews               # Create a new review
    PUT    /api/v2/platform/komplex/reviews/:id           # Update a review
    DELETE /api/v2/platform/komplex/reviews/:id           # Delete a review
    PUT    /api/v2/platform/komplex/reviews/:id/approve   # Approve a review
    ```

10. **Search API**
    ```
    GET    /api/v2/platform/komplex/search                # Search listings with advanced filtering
    ```

### Implementation Structure

The Komplex module will be implemented as a Rails Engine and Spree extension with the following structure:

```
komplex/
├── app/
│   ├── controllers/
│   │   ├── komplex/
│   │   │   ├── api/
│   │   │   │   └── v2/
│   │   │   │       ├── platform/
│   │   │   │       └── storefront/
│   │   │   ├── admin/
│   │   │   └── storefront/
│   ├── models/
│   │   └── komplex/
│   ├── views/
│   │   └── komplex/
│   ├── serializers/
│   │   └── komplex/
│   ├── services/
│   │   └── komplex/
│   └── workers/
│       └── komplex/
├── config/
│   ├── routes.rb
│   └── initializers/
├── db/
│   └── migrate/
├── lib/
│   ├── komplex/
│   │   ├── engine.rb
│   │   └── version.rb
│   ├── generators/
│   └── komplex.rb
├── spec/
├── Gemfile
├── komplex.gemspec
├── LICENSE
└── README.md
```

### Integration with Spree Models

1. **User Extension**
   ```ruby
   # app/models/spree/user_decorator.rb
   module Spree
     module UserDecorator
       def self.prepended(base)
         base.has_one :vendor, class_name: 'Komplex::Vendor', dependent: :destroy
         base.has_many :listings, through: :vendor, class_name: 'Komplex::Listing'
         base.has_many :reviews, class_name: 'Komplex::Review', dependent: :destroy
       end

       def vendor?
         vendor.present?
       end

       def approved_vendor?
         vendor? && vendor.approved?
       end
     end
   end

   Spree::User.prepend Spree::UserDecorator
   ```

2. **Product Integration**
   ```ruby
   # app/models/komplex/listing_decorator.rb
   module Komplex
     module ListingDecorator
       def to_spree_product
         product = Spree::Product.find_or_initialize_by(name: title)
         product.description = description
         product.price = price
         product.shipping_category = Spree::ShippingCategory.find_or_create_by(name: 'Default')
         product.available_on = published_at
         product.stores = [vendor.store]

         # Set product properties based on listing type
         case listable_type
         when 'Komplex::Property'
           setup_property_product_properties(product)
         when 'Komplex::Restaurant'
           setup_restaurant_product_properties(product)
         when 'Komplex::Service'
           setup_service_product_properties(product)
         end

         product.save
         product
       end

       private

       def setup_property_product_properties(product)
         property = listable
         add_product_property(product, 'property_type', property.property_type)
         add_product_property(product, 'listing_type', property.listing_type)
         add_product_property(product, 'bedrooms', property.bedrooms.to_s)
         add_product_property(product, 'bathrooms', property.bathrooms.to_s)
         add_product_property(product, 'area', "#{property.area} #{property.area_unit}")
         add_product_property(product, 'address', property.address)
       end

       def setup_restaurant_product_properties(product)
         restaurant = listable
         add_product_property(product, 'cuisine_type', restaurant.cuisine_type)
         add_product_property(product, 'address', restaurant.address)
         add_product_property(product, 'delivery_available', restaurant.delivery_available.to_s)
         add_product_property(product, 'takeout_available', restaurant.takeout_available.to_s)
       end

       def setup_service_product_properties(product)
         service = listable
         add_product_property(product, 'service_category', service.category.name)
         add_product_property(product, 'pricing_model', service.pricing_model)
         add_product_property(product, 'duration', "#{service.duration_minutes} minutes") if service.duration_minutes
         add_product_property(product, 'remote_available', service.remote_available.to_s)
       end

       def add_product_property(product, property_name, property_value)
         product.product_properties.build(
           property: Spree::Property.find_or_create_by(name: property_name),
           value: property_value
         )
       end
     end
   end

   Komplex::Listing.prepend Komplex::ListingDecorator
   ```

3. **Store Integration**
   ```ruby
   # app/models/komplex/vendor_decorator.rb
   module Komplex
     module VendorDecorator
       def self.prepended(base)
         base.has_one :store, class_name: 'Spree::Store', dependent: :nullify
         base.after_create :create_store
       end

       private

       def create_store
         self.store = Spree::Store.create(
           name: name,
           url: name.parameterize,
           mail_from_address: user.email,
           default_currency: 'USD',
           supported_currencies: 'USD',
           default_locale: 'en',
           supported_locales: 'en'
         )
       end
     end
   end

   Komplex::Vendor.prepend Komplex::VendorDecorator
   ```

### Background Workers

1. **Approval Notification Worker**
   ```ruby
   # app/workers/komplex/approval_notification_worker.rb
   module Komplex
     class ApprovalNotificationWorker
       include Sidekiq::Worker

       def perform(resource_type, resource_id, status)
         resource_class = resource_type.constantize
         resource = resource_class.find(resource_id)

         case resource_type
         when 'Komplex::Vendor'
           Komplex::VendorMailer.status_update(resource, status).deliver_now
         when 'Komplex::Listing'
           Komplex::ListingMailer.status_update(resource, status).deliver_now
         end
       end
     end
   end
   ```

2. **Commission Processing Worker**
   ```ruby
   # app/workers/komplex/commission_processing_worker.rb
   module Komplex
     class CommissionProcessingWorker
       include Sidekiq::Worker

       def perform(order_id)
         order = Spree::Order.find(order_id)
         return unless order.completed?

         order.line_items.each do |line_item|
           next unless line_item.product.vendor_id.present?

           vendor = Komplex::Vendor.find_by(id: line_item.product.vendor_id)
           next unless vendor

           commission_rate = vendor.commission_rate
           item_total = line_item.amount
           commission_amount = item_total * commission_rate
           vendor_amount = item_total - commission_amount

           Komplex::Commission.create!(
             vendor: vendor,
             order: order,
             line_item: line_item,
             vendor_amount: vendor_amount,
             commission_amount: commission_amount
           )
         end
       end
     end
   end
   ```

3. **Payout Processing Worker**
   ```ruby
   # app/workers/komplex/payout_processing_worker.rb
   module Komplex
     class PayoutProcessingWorker
       include Sidekiq::Worker

       def perform(payout_id)
         payout = Komplex::Payout.find(payout_id)
         return unless payout.pending?

         payout.update(status: 'processing')

         # Integration with payment gateway for vendor payout
         begin
           # Process payout through payment gateway
           transaction_id = process_payout(payout)
           payout.update(
             status: 'completed',
             transaction_id: transaction_id,
             processed_at: Time.current
           )
         rescue => e
           payout.update(
             status: 'failed',
             notes: "Error: #{e.message}"
           )
         end
       end

       private

       def process_payout(payout)
         # Implementation depends on payment gateway
         # This is a placeholder
         "txn_#{SecureRandom.hex(10)}"
       end
     end
   end
   ```

## Implementation Plan

### Phase 1: Core Infrastructure

1. Set up the Rails Engine structure
2. Create database migrations for core tables
3. Implement core models (Merchant, Listing, Category)
4. Set up Spree model extensions
5. Implement basic API endpoints

### Phase 2: Listing Types

1. Implement Property listing type
2. Implement Restaurant listing type
3. Implement Service listing type
4. Create search and filtering functionality
5. Implement listing approval workflow

### Phase 3: Merchant Management

1. Implement merchant registration and onboarding
2. Create merchant dashboard
3. Implement merchant approval workflow
4. Set up commission and payout system
5. Create merchant analytics

### Phase 4: Marketing Features

1. Implement Advertisements
2. Create campaign management
3. Set up notification system

### Phase 5: Integration and Testing

1. Integrate with Spree Admin
2. Integrate with Spree Storefront
3. Write comprehensive tests
4. Create documentation
5. Package as a gem

## Deployment and Scalability

### Installation

The Komplex module will be packaged as a Ruby gem that can be installed in any Spree Commerce application:

```ruby
# In Gemfile
gem 'komplex', '~> 1.0'
```

After installation, run the following commands:

```bash
bundle install
rails g komplex:install
rails db:migrate
```

### Scalability Considerations

1. **Database Indexing**
   - All tables have appropriate indexes for efficient querying
   - Use of polymorphic associations for flexible listing types

2. **Background Processing**
   - All time-consuming tasks are handled by background workers
   - Notifications, approvals, and payouts are processed asynchronously

3. **Caching Strategy**
   - Implement fragment caching for listing views
   - Cache search results and filter options

4. **Search Optimization**
   - Use Elasticsearch for advanced search capabilities
   - Implement geospatial search for location-based queries

## Extensibility

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

## Conclusion

The Komplex module provides a comprehensive solution for creating a multi-merchant marketplace on top of SpreeCommerce. By leveraging Spree's existing e-commerce capabilities and extending them with marketplace features, Komplex enables businesses to quickly launch and scale their marketplace platforms.

The modular design allows for easy customization and extension, making it suitable for a wide range of marketplace types, from property and restaurant listings to service marketplaces and beyond.
