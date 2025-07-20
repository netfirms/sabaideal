# Komplex: Multi-Merchant Marketplace Extension for SpreeCommerce

## High-Level Architecture

### System Overview

Komplex is a modular, multi-merchant marketplace extension for SpreeCommerce that enables the creation and management of various listing types including real estate properties, restaurants, services, and advertisements. Built as a Rails Engine and Spree extension, Komplex follows the standard Rails MVC (Model-View-Controller) architecture while integrating seamlessly with the Spree Commerce platform.

**Core Module Goals:**
- Enable merchants to register and manage their marketplace presence
- Support multiple listing types (real estate properties, restaurants, services, etc.)
- Provide robust search and filtering capabilities
- Implement commission and payout logic for marketplace transactions
- Support approval workflows for listings and merchants
- Enable platform-wide and merchant-specific promotions and advertisements

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
│             │             │             │                            │
│ Real Estate │  Restaurant │  Service    │                            │
│  Listings   │  Listings   │  Listings   │                            │
│             │             │             │                            │
├─────────────┴─────────────┴─────────────┴────────────────────────────┤
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
   - View transaction history
   - (Future: Submit reviews and ratings)

2. **Merchant**
   - Create and manage listings (real estate properties, restaurants, services)
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
   - Manage categories

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
│              │     │               │     │  (Future)     │
└──────┬───────┘     └───────┬───────┘     └───────────────┘
       │                     │
       ▼                     ▼
┌──────────────┐     ┌───────────────┐     ┌───────────────┐
│              │     │               │     │               │
│ Advertisement│────▶│  Marketplace  │────▶│  Commission   │
│  Management  │     │  Transactions │     │  Processing   │
│              │     │               │     │  (Future)     │
└──────────────┘     └───────────────┘     └───────────────┘
```

### Integration with Spree Commerce

Komplex integrates with Spree Commerce by:

1. **Extending Spree Models**
   - Extending `Spree::User` to support merchant capabilities
   - Leveraging `Spree::Property` for real estate property attributes
   - (Future: Using `Spree::Order` for marketplace transactions)
   - (Future: Extending `Spree::Store` for multi-merchant support)

2. **Admin Interface Integration**
   - Adding merchant management to Spree Admin
   - Integrating listing approval workflows
   - Managing advertisements
   - (Future: Adding commission and payout management)

3. **Storefront Integration**
   - Implementing listing browsing and filtering
   - Adding merchant profile pages
   - Supporting multiple listing types (real estate properties, restaurants, services)

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
                    │                        │  │ condition     │       │
                    │                        │  │ category      │       │
                    │                        │  │ ...           │       │
                    │                        │  └───────────────┘       │
                    │                        │                          │
                    │                        │  ┌───────────────┐       │
                    │                        │  │ komplex_      │       │
                    │                        │  │ properties    │       │
                    │                        │  ├───────────────┤       │
                    │                        │  │ id            │       │
                    │                        │  │ listing_id    │───────┘
                    │                        │  │ property_type │
                    │                        │  │ bedrooms      │
                    │                        │  │ bathrooms     │
                    │                        │  │ area          │
                    │                        │  │ address       │
                    │                        │  │ ...           │
                    │                        │  └───────────────┘
                    │
                    │                        ┌───────────────┐
                    │                        │ komplex_      │
                    │                        │ restaurants   │
                    │                        ├───────────────┤
                    │                        │ id            │
                    │                        │ listing_id    │◀──────┐
                    │                        │ cuisine_type  │       │
                    │                        │ menu_items    │       │
                    │                        │ opening_hours │       │
                    │                        │ ...           │       │
                    │                        └───────────────┘       │
                    │                                                │
                    │                        ┌───────────────┐       │
                    │                        │ komplex_      │       │
                    │                        │ services      │       │
                    │                        ├───────────────┤       │
                    │                        │ id            │       │
                    │                        │ listing_id    │◀──────┼───────┐
                    │                        │ pricing_model │       │       │
                    │                        │ category_id   │       │       │
                    │                        │ ...           │       │       │
                    │                        └───────────────┘       │       │
                    │                                                │       │
┌───────────────┐   │   ┌───────────────┐                           │       │
│ komplex_      │   │   │ komplex_      │                           │       │
│ conversations │   │   │ advertisements│                           │       │
├───────────────┤   │   ├───────────────┤                           │       │
│ id            │   │   │ id            │                           │       │
│ listing_id    │───┘   │ title         │                           │       │
│ buyer_id      │       │ description   │                           │       │
│ merchant_id   │       │ placement     │                           │       │
│ status        │       │ ad_type       │                           │       │
│ ...           │       │ starts_at     │                           │       │
└───────────────┘       │ ends_at       │                           │       │
                        │ merchant_id   │                           │       │
                        │ listing_id    │◀──────────────────────────┘       │
                        │ ...           │                                   │
                        └───────────────┘                                   │
                                                                           │
┌───────────────┐                                                          │
│ komplex_      │                                                          │
│ categories    │                                                          │
├───────────────┤                                                          │
│ id            │                                                          │
│ name          │                                                          │
│ description   │                                                          │
│ parent_id     │                                                          │
│ position      │                                                          │
│ ...           │                                                          │
└───────────────┘                                                          │
                                                                           │
                        ┌───────────────┐                                  │
                        │ komplex_      │                                  │
                        │ listings      │◀─────────────────────────────────┘
                        ├───────────────┤
                        │ (same as above)│
                        └───────────────┘

# Future Models (Not Yet Implemented)
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│ komplex_      │       │ komplex_      │       │ komplex_      │
│ commissions   │       │ payouts       │       │ messages      │
├───────────────┤       ├───────────────┤       ├───────────────┤
│ id            │       │ id            │       │ id            │
│ merchant_id   │       │ merchant_id   │       │ conversation_id│
│ order_id      │       │ amount        │       │ sender_id     │
│ amount        │       │ status        │       │ content       │
│ status        │       │ ...           │       │ read          │
│ ...           │       └───────────────┘       │ ...           │
└───────────────┘                               └───────────────┘

┌───────────────┐
│ komplex_      │
│ reviews       │
├───────────────┤
│ id            │
│ listing_id    │
│ user_id       │
│ rating        │
│ comment       │
│ status        │
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
     t.string "condition", default: "new", null: false  # new, like_new, good, fair, poor
     t.string "category", null: false  # property, restaurant, service, other
     t.datetime "published_at"
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["status"], name: "index_komplex_listings_on_status"
     t.index ["featured"], name: "index_komplex_listings_on_featured"
     t.index ["category"], name: "index_komplex_listings_on_category"
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

1. **komplex_properties** (Used by RealEstateProperty model)
   ```ruby
   create_table "komplex_properties", force: :cascade do |t|
     t.references "property", foreign_key: { to_table: "spree_properties" }, optional: true
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
     t.string "cuisine_type", null: false
     t.text "menu_items"  # Serialized as YAML
     t.text "opening_hours"  # Serialized as YAML
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
     t.references "category", foreign_key: { to_table: "komplex_categories" }, optional: true
     t.string "pricing_model", null: false  # hourly, fixed, per_session, custom
     t.integer "duration_minutes"
     t.text "service_area"
     t.boolean "remote_available", default: false
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["pricing_model"], name: "index_komplex_services_on_pricing_model"
   end
   ```


#### Marketing Tables

1. **komplex_advertisements**
   ```ruby
   create_table "komplex_advertisements", force: :cascade do |t|
     t.string "title", null: false
     t.text "description", null: false
     t.string "placement", null: false  # homepage, search_results, category_page
     t.string "ad_type", null: false    # banner, sidebar, featured
     t.references "merchant", null: false, foreign_key: { to_table: "komplex_merchants" }
     t.datetime "starts_at", null: false
     t.datetime "ends_at", null: false
     t.decimal "cost", precision: 10, scale: 2, null: false
     t.string "status", default: "pending", null: false  # pending, active, inactive
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["placement"], name: "index_komplex_advertisements_on_placement"
     t.index ["ad_type"], name: "index_komplex_advertisements_on_ad_type"
     t.index ["status"], name: "index_komplex_advertisements_on_status"
     t.index ["starts_at", "ends_at"], name: "index_komplex_advertisements_on_date_range"
   end
   ```

#### User Interaction Tables

1. **komplex_conversations**
   ```ruby
   create_table "komplex_conversations", force: :cascade do |t|
     t.references "listing", null: false, foreign_key: { to_table: "komplex_listings" }
     t.references "buyer", null: false, foreign_key: { to_table: "spree_users" }
     t.references "merchant", null: false, foreign_key: { to_table: "komplex_merchants" }
     t.string "status", default: "active", null: false  # active, archived
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["status"], name: "index_komplex_conversations_on_status"
   end
   ```

#### Future Tables (Not Yet Implemented)

1. **komplex_messages**
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

2. **komplex_commissions**
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

3. **komplex_payouts**
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

4. **komplex_reviews**
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

### API Design

#### RESTful API Endpoints

1. **Merchants API**
   ```
   GET    /api/v2/platform/komplex/merchants                # List all merchants
   GET    /api/v2/platform/komplex/merchants/:id            # Get a specific merchant
   POST   /api/v2/platform/komplex/merchants                # Create a new merchant
   PUT    /api/v2/platform/komplex/merchants/:id            # Update a merchant
   DELETE /api/v2/platform/komplex/merchants/:id            # Delete a merchant
   PUT    /api/v2/platform/komplex/merchants/:id/approve    # Approve a merchant
   PUT    /api/v2/platform/komplex/merchants/:id/reject     # Reject a merchant
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

3. **Real Estate Properties API**
   ```
   GET    /api/v2/platform/komplex/real_estate_properties             # List all real estate properties
   GET    /api/v2/platform/komplex/real_estate_properties/:id         # Get a specific real estate property
   POST   /api/v2/platform/komplex/real_estate_properties             # Create a new real estate property
   PUT    /api/v2/platform/komplex/real_estate_properties/:id         # Update a real estate property
   DELETE /api/v2/platform/komplex/real_estate_properties/:id         # Delete a real estate property
   ```

4. **Restaurants API**
   ```
   GET    /api/v2/platform/komplex/restaurants            # List all restaurants
   GET    /api/v2/platform/komplex/restaurants/:id        # Get a specific restaurant
   POST   /api/v2/platform/komplex/restaurants            # Create a new restaurant
   PUT    /api/v2/platform/komplex/restaurants/:id        # Update a restaurant
   DELETE /api/v2/platform/komplex/restaurants/:id        # Delete a restaurant
   ```

5. **Services API**
   ```
   GET    /api/v2/platform/komplex/services               # List all services
   GET    /api/v2/platform/komplex/services/:id           # Get a specific service
   POST   /api/v2/platform/komplex/services               # Create a new service
   PUT    /api/v2/platform/komplex/services/:id           # Update a service
   DELETE /api/v2/platform/komplex/services/:id           # Delete a service
   ```

6. **Advertisements API**
   ```
   GET    /api/v2/platform/komplex/advertisements         # List all advertisements
   GET    /api/v2/platform/komplex/advertisements/:id     # Get a specific advertisement
   POST   /api/v2/platform/komplex/advertisements         # Create a new advertisement
   PUT    /api/v2/platform/komplex/advertisements/:id     # Update an advertisement
   DELETE /api/v2/platform/komplex/advertisements/:id     # Delete an advertisement
   ```

7. **Categories API**
   ```
   GET    /api/v2/platform/komplex/categories             # List all categories
   GET    /api/v2/platform/komplex/categories/:id         # Get a specific category
   POST   /api/v2/platform/komplex/categories             # Create a new category
   PUT    /api/v2/platform/komplex/categories/:id         # Update a category
   DELETE /api/v2/platform/komplex/categories/:id         # Delete a category
   ```

8. **Conversations API**
   ```
   GET    /api/v2/platform/komplex/conversations          # List all conversations
   GET    /api/v2/platform/komplex/conversations/:id      # Get a specific conversation
   POST   /api/v2/platform/komplex/conversations          # Create a new conversation
   PUT    /api/v2/platform/komplex/conversations/:id      # Update a conversation
   PUT    /api/v2/platform/komplex/conversations/:id/archive # Archive a conversation
   PUT    /api/v2/platform/komplex/conversations/:id/activate # Activate a conversation
   ```

9. **Search API**
   ```
   GET    /api/v2/platform/komplex/search                # Search listings with advanced filtering
   ```

#### Future API Endpoints (Not Yet Implemented)

1. **Commissions API**
   ```
   GET    /api/v2/platform/komplex/commissions            # List all commissions
   GET    /api/v2/platform/komplex/commissions/:id        # Get a specific commission
   PUT    /api/v2/platform/komplex/commissions/:id/pay    # Mark a commission as paid
   ```

2. **Payouts API**
   ```
   GET    /api/v2/platform/komplex/payouts                # List all payouts
   GET    /api/v2/platform/komplex/payouts/:id            # Get a specific payout
   POST   /api/v2/platform/komplex/payouts                # Create a new payout
   PUT    /api/v2/platform/komplex/payouts/:id            # Update a payout
   ```

3. **Messages API**
   ```
   GET    /api/v2/platform/komplex/messages               # List all messages
   GET    /api/v2/platform/komplex/messages/:id           # Get a specific message
   POST   /api/v2/platform/komplex/messages               # Create a new message
   PUT    /api/v2/platform/komplex/messages/:id/read      # Mark a message as read
   ```

4. **Reviews API**
   ```
   GET    /api/v2/platform/komplex/reviews               # List all reviews
   GET    /api/v2/platform/komplex/reviews/:id           # Get a specific review
   POST   /api/v2/platform/komplex/reviews               # Create a new review
   PUT    /api/v2/platform/komplex/reviews/:id           # Update a review
   DELETE /api/v2/platform/komplex/reviews/:id           # Delete a review
   PUT    /api/v2/platform/komplex/reviews/:id/approve   # Approve a review
   ```

### Implementation Structure

The Komplex module is implemented as a Rails Engine and Spree extension with the following structure:

```
app/
├── controllers/
│   └── komplex/
│       ├── admin/
│       │   ├── advertisements_controller.rb
│       │   ├── listings_controller.rb
│       │   ├── merchants_controller.rb
│       │   ├── messages_controller.rb
│       │   ├── real_estate_properties_controller.rb
│       │   ├── restaurants_controller.rb
│       │   └── services_controller.rb
│       └── storefront/
│           ├── listings_controller.rb
│           ├── merchants_controller.rb
│           ├── real_estate_properties_controller.rb
│           ├── restaurants_controller.rb
│           └── services_controller.rb
├── models/
│   └── komplex/
│       ├── advertisement.rb
│       ├── category.rb
│       ├── conversation.rb
│       ├── listing.rb
│       ├── merchant.rb
│       ├── real_estate_property.rb
│       ├── restaurant.rb
│       └── service.rb
├── views/
│   └── komplex/
│       ├── admin/
│       │   ├── advertisements/
│       │   ├── listings/
│       │   ├── merchants/
│       │   ├── real_estate_properties/
│       │   ├── restaurants/
│       │   └── services/
│       └── storefront/
│           ├── listings/
│           ├── merchants/
│           ├── real_estate_properties/
│           └── restaurants/
├── helpers/
│   └── komplex/
├── assets/
│   ├── images/
│   │   └── komplex/
│   ├── javascripts/
│   │   └── komplex/
│   └── stylesheets/
│       └── komplex/
└── services/
    └── komplex/

config/
├── routes.rb
└── initializers/

db/
└── migrate/

lib/
├── komplex/
│   ├── engine.rb
│   └── version.rb
└── komplex.rb

spec/
├── controllers/
│   └── komplex/
├── models/
│   └── komplex/
└── features/
```

This structure follows Rails conventions and organizes the code by functionality, with separate directories for controllers, models, views, and other components.

### Integration with Spree Models

1. **User Extension**
   ```ruby
   # app/models/spree/user_decorator.rb
   module Spree
     module UserDecorator
       def self.prepended(base)
         base.has_one :merchant, class_name: 'Komplex::Merchant', dependent: :destroy
         base.has_many :listings, through: :merchant, class_name: 'Komplex::Listing'
         # Future: base.has_many :reviews, class_name: 'Komplex::Review', dependent: :destroy
       end

       def merchant?
         merchant.present?
       end

       def approved_merchant?
         merchant? && merchant.approved?
       end
     end
   end

   Spree::User.prepend Spree::UserDecorator
   ```

2. **Real Estate Property Integration**
   ```ruby
   # app/models/komplex/real_estate_property.rb
   module Komplex
     class RealEstateProperty < ApplicationRecord
       self.table_name = 'komplex_properties'

       belongs_to :property, class_name: 'Spree::Property', optional: true
       has_one :listing, class_name: 'Komplex::Listing', as: :listable, dependent: :destroy
       accepts_nested_attributes_for :listing

       validates :property_type, presence: true
       validates :address, uniqueness: { scope: [:property_type, :listing_type, :bedrooms, :bathrooms, :area, :area_unit], 
                                       message: "already exists for a property with the same details" }
     end
   end
   ```

3. **Future Store Integration**
   ```ruby
   # This integration is planned for future implementation
   module Komplex
     module MerchantDecorator
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

   # Komplex::Merchant.prepend Komplex::MerchantDecorator
   ```

### Future Background Workers

The following background workers are planned for future implementation to handle asynchronous tasks in the Komplex marketplace:

1. **Approval Notification Worker**
   ```ruby
   # app/workers/komplex/approval_notification_worker.rb (Future Implementation)
   module Komplex
     class ApprovalNotificationWorker
       include Sidekiq::Worker

       def perform(resource_type, resource_id, status)
         resource_class = resource_type.constantize
         resource = resource_class.find(resource_id)

         case resource_type
         when 'Komplex::Merchant'
           Komplex::MerchantMailer.status_update(resource, status).deliver_now
         when 'Komplex::Listing'
           Komplex::ListingMailer.status_update(resource, status).deliver_now
         end
       end
     end
   end
   ```

2. **Commission Processing Worker**
   ```ruby
   # app/workers/komplex/commission_processing_worker.rb (Future Implementation)
   module Komplex
     class CommissionProcessingWorker
       include Sidekiq::Worker

       def perform(order_id)
         order = Spree::Order.find(order_id)
         return unless order.completed?

         order.line_items.each do |line_item|
           next unless line_item.product.merchant_id.present?

           merchant = Komplex::Merchant.find_by(id: line_item.product.merchant_id)
           next unless merchant

           commission_rate = merchant.commission_rate
           item_total = line_item.amount
           commission_amount = item_total * commission_rate
           merchant_amount = item_total - commission_amount

           Komplex::Commission.create!(
             merchant: merchant,
             order: order,
             line_item: line_item,
             merchant_amount: merchant_amount,
             commission_amount: commission_amount
           )
         end
       end
     end
   end
   ```

3. **Payout Processing Worker**
   ```ruby
   # app/workers/komplex/payout_processing_worker.rb (Future Implementation)
   module Komplex
     class PayoutProcessingWorker
       include Sidekiq::Worker

       def perform(payout_id)
         payout = Komplex::Payout.find(payout_id)
         return unless payout.pending?

         payout.update(status: 'processing')

         # Integration with payment gateway for merchant payout
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

## Implementation Status and Future Plans

### Completed Features

1. **Core Infrastructure**
   - Rails Engine structure
   - Database migrations for core tables
   - Core models (Merchant, Listing, Category)
   - Basic Spree model extensions
   - Admin and storefront controllers

2. **Listing Types**
   - Real Estate Property listing type
   - Restaurant listing type
   - Service listing type
   - Basic search and filtering functionality
   - Listing approval workflow

3. **Merchant Management**
   - Merchant registration and onboarding
   - Basic merchant dashboard
   - Merchant approval workflow

4. **Marketing Features**
   - Basic Advertisement functionality

5. **User Interaction**
   - Conversation system for buyer-merchant communication

### Planned Future Enhancements

1. **Transaction System**
   - Commission calculation and tracking
   - Merchant payout system
   - Integration with payment gateways

2. **Review System**
   - User reviews and ratings for listings
   - Review moderation workflow

3. **Enhanced Marketing Features**
   - Advanced advertisement targeting
   - Campaign management
   - Notification system

4. **Analytics and Reporting**
   - Merchant analytics dashboard
   - Platform-wide reporting
   - Performance metrics

5. **Enhanced Integration**
   - Deeper integration with Spree Order system
   - Multi-store support for merchants
   - API enhancements for third-party integrations

## Deployment and Scalability

### Current Installation

The Komplex module is currently integrated directly into the main application:

```ruby
# In Gemfile
# The module is part of the main application codebase
```

### Future Packaging

In the future, the Komplex module could be packaged as a Ruby gem for easier installation in any Spree Commerce application:

```ruby
# In Gemfile (future)
gem 'komplex', '~> 1.0'
```

After installation, users would run:

```bash
bundle install
rails g komplex:install
rails db:migrate
```

### Scalability Considerations

1. **Database Indexing**
   - All tables have appropriate indexes for efficient querying
   - Use of polymorphic associations for flexible listing types (real estate properties, restaurants, services)
   - Category-based filtering with optimized queries

2. **Future Background Processing**
   - Plan to move time-consuming tasks to background workers
   - Notifications, approvals, and payouts will be processed asynchronously

3. **Caching Strategy**
   - Implement fragment caching for listing views
   - Cache search results and filter options
   - Use Russian Doll caching for nested resources

4. **Search Optimization**
   - Implement basic search with database queries
   - Future: Integrate Elasticsearch for advanced search capabilities
   - Future: Implement geospatial search for location-based queries

## Extensibility

The Komplex module is designed to be extensible in several ways:

1. **New Listing Types**
   - The polymorphic `listable` association allows for easy addition of new listing types
   - Current implementation includes real estate properties, restaurants, and services
   - Developers can create new listing type models following the same pattern

2. **Category System**
   - Hierarchical category system with parent-child relationships
   - Categories can be used for organizing and filtering listings
   - New categories can be added through the admin interface

3. **Integration Points**
   - Integration with Spree::User for merchant capabilities
   - Integration with Spree::Property for real estate property attributes
   - Future integration points planned for orders and payment processing

4. **Customization**
   - Views can be overridden in the main application
   - Controllers follow RESTful conventions for predictable behavior
   - Models use standard Rails patterns for easy extension

5. **Future Extensibility Plans**
   - API expansion for third-party integrations
   - Webhook system for external notifications
   - Plugin architecture for additional marketplace features

## Conclusion

The Komplex module provides a comprehensive solution for creating a multi-merchant marketplace on top of SpreeCommerce. By leveraging Spree's existing e-commerce capabilities and extending them with marketplace features, Komplex enables businesses to quickly launch and scale their marketplace platforms.

The current implementation includes core marketplace functionality with support for real estate properties, restaurants, and services listings. The modular design allows for easy customization and extension, making it suitable for a wide range of marketplace types.

Future development will focus on enhancing the transaction system, implementing reviews and ratings, expanding marketing features, adding analytics and reporting capabilities, and deepening the integration with Spree Commerce.

This architecture document serves as both documentation of the current state and a roadmap for future development, ensuring that the Komplex marketplace extension continues to evolve in a structured and maintainable way.
