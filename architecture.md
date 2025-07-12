# SabaiDeal Architecture

# Multi-Vendor Marketplace for Property and Service Listings

## High-Level Architecture

### System Overview

SabaiDeal is evolving from a standard e-commerce application into a comprehensive multi-vendor marketplace specializing in property listings (for rent and sale) and service listings. Built on Ruby on Rails 8.0 with the Spree Commerce platform (v5.1), the application follows a standard Rails MVC (Model-View-Controller) architecture with additional components for background processing, caching, and third-party integrations.

**Core Platform Goals:**
- Enable property owners and real estate agents to list properties for rent or sale
- Allow service providers to offer various services related to properties
- Provide robust search and filtering capabilities for users to find properties and services
- Facilitate communication between buyers/renters and sellers/landlords/service providers
- Support secure payment processing for bookings and service fees

### Component Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SabaiDeal Marketplace                         │
├─────────────┬─────────────┬─────────────────┬──────────────────────┤
│             │             │                 │                      │
│  Core Spree │  Property   │    Service      │  User Management     │
│  Engine     │  Management │    Management   │                      │
│             │             │                 │                      │
├─────────────┼─────────────┼─────────────────┼──────────────────────┤
│             │             │                 │                      │
│  Search &   │  Booking &  │  Payment        │  Notification &      │
│  Filtering  │  Messaging  │  Processing     │  Communication       │
│             │             │                 │                      │
├─────────────┴─────────────┴─────────────────┴──────────────────────┤
│                                                                     │
│                      Third-Party Integrations                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │ Payment      │  │ Mapping      │  │ Analytics &  │              │
│  │ Gateways     │  │ Services     │  │ Marketing    │              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### User Roles and Permissions

1. **General User**
   - Browse property and service listings
   - Search and filter listings
   - Create and manage account
   - Contact property owners and service providers
   - Book services and schedule property viewings
   - Submit reviews and ratings
   - View transaction history

2. **Property Owner**
   - All General User permissions
   - Create and manage property listings
   - Upload property images and documents
   - Receive and respond to inquiries
   - Accept or reject booking requests
   - View analytics for their listings
   - Manage availability calendar

3. **Real Estate Agent**
   - All Property Owner permissions
   - Manage multiple property listings
   - Associate listings with property owners
   - Generate property reports
   - Access advanced analytics

4. **Service Provider**
   - All General User permissions
   - Create and manage service listings
   - Define service areas and availability
   - Set pricing models (hourly, fixed, etc.)
   - Receive and respond to service requests
   - Manage service bookings
   - View service analytics

5. **Administrator**
   - Full system access
   - Manage all users and listings
   - Review and approve/reject listings
   - Configure system settings
   - Access comprehensive analytics
   - Manage payment processing
   - Handle dispute resolution

### Data Flow Diagram

```
┌──────────────┐     ┌───────────────┐     ┌───────────────┐
│              │     │               │     │               │
│  Property    │────▶│  Listing      │◀────│  Service      │
│  Owner       │     │  Management   │     │  Provider     │
│              │     │               │     │               │
└──────────────┘     └───────┬───────┘     └──────────────┘
                             │
                             ▼
┌──────────────┐     ┌───────────────┐     ┌───────────────┐
│              │     │               │     │               │
│  Search &    │◀────│  Marketplace  │────▶│  Payment      │
│  Filtering   │     │  Platform     │     │  Processing   │
│              │     │               │     │               │
└──────┬───────┘     └───────┬───────┘     └───────┬───────┘
       │                     │                     │
       ▼                     ▼                     ▼
┌──────────────┐     ┌───────────────┐     ┌───────────────┐
│              │     │               │     │               │
│  General     │────▶│  Booking &    │────▶│  Notification │
│  User        │     │  Messaging    │     │  System       │
│              │     │               │     │               │
└──────────────┘     └───────────────┘     └───────────────┘
```

### Technology Stack

1. **Core Framework**
   - Ruby 3.3.0
   - Rails 8.0.0
   - Spree Commerce 5.1

2. **Database**
   - PostgreSQL with PostGIS extension for geospatial data

3. **Frontend**
   - Hotwire (Turbo and Stimulus) for SPA-like interactivity
   - Import maps for JavaScript module management
   - Responsive design with CSS frameworks

4. **Search and Filtering**
   - Elasticsearch for advanced search capabilities
   - Geospatial search for location-based queries

5. **Background Processing**
   - Sidekiq for asynchronous job processing
   - Redis for caching and job queue

6. **File Storage**
   - ActiveStorage with cloud storage provider (AWS S3)
   - Image processing for property photos

7. **Communication**
   - ActionCable for real-time messaging
   - Email notifications via SMTP

8. **Payment Processing**
   - Stripe for payment processing
   - PayPal Checkout as alternative payment method

9. **External Integrations**
   - Google Maps API for property location
   - Google Analytics for usage tracking
   - Klaviyo for email marketing

10. **Monitoring and Error Tracking**
    - Sentry for error tracking and performance monitoring

### Deployment Strategy

The application is containerized using Docker with a multi-stage build process for production deployment:

1. **Development Environment**
   - Docker Compose for local development
   - Hot reloading for rapid iteration

2. **Staging Environment**
   - Replicates production setup
   - Automated deployments from staging branch
   - Synthetic data for testing

3. **Production Environment**
   - Kubernetes orchestration
   - Horizontal scaling for web and worker nodes
   - Database replication and backups
   - CDN for static assets
   - SSL/TLS encryption
   - Regular security audits

4. **Continuous Integration/Deployment**
   - Automated testing pipeline
   - Deployment automation
   - Feature flags for gradual rollout

## Low-Level Architecture

### Database Schema Design

#### Entity-Relationship Diagram (ERD)

The database schema extends the core Spree Commerce tables with new models for property and service listings:

```
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│ spree_users   │       │ listings      │       │ properties    │
├───────────────┤       ├───────────────┤       ├───────────────┤
│ id            │       │ id            │       │ id            │
│ email         │◀──┐   │ title         │       │ listing_id    │────┐
│ encrypted_pass│   │   │ description   │       │ property_type │    │
│ role          │   │   │ price         │       │ bedrooms      │    │
│ ...           │   │   │ listable_id   │◀──────│ bathrooms     │    │
└───────────────┘   │   │ listable_type │       │ area          │    │
                    │   │ user_id       │────┘  │ address       │    │
                    │   │ status        │       │ latitude      │    │
                    │   │ ...           │       │ longitude     │    │
                    │   └───────────────┘       │ listing_type  │    │
                    │                           │ ...           │    │
                    │                           └───────────────┘    │
                    │                                                │
                    │   ┌───────────────┐       ┌───────────────┐   │
                    │   │ services      │       │ bookings      │   │
                    │   ├───────────────┤       ├───────────────┤   │
                    │   │ id            │       │ id            │   │
                    │   │ listing_id    │────┘  │ listing_id    │◀──┘
                    │   │ category_id   │       │ user_id       │────┐
                    │   │ pricing_model │       │ status        │    │
                    │   │ price         │       │ start_date    │    │
                    │   │ duration      │       │ end_date      │    │
                    └───│ user_id       │       │ price         │    │
                        │ ...           │       │ ...           │    │
                        └───────────────┘       └───────────────┘    │
                                                                     │
                        ┌───────────────┐       ┌───────────────┐    │
                        │ amenities     │       │ messages      │    │
                        ├───────────────┤       ├───────────────┤    │
                        │ id            │       │ id            │    │
                        │ name          │       │ booking_id    │◀───┘
                        │ icon          │       │ sender_id     │────┐
                        │ ...           │       │ content       │    │
                        └───────┬───────┘       │ read          │    │
                                │               │ ...           │    │
                                │               └───────────────┘    │
                                ▼                                    │
                        ┌───────────────┐                           │
                        │ property_     │                           │
                        │ amenities     │                           │
                        ├───────────────┤       ┌───────────────┐   │
                        │ property_id   │       │ reviews       │   │
                        │ amenity_id    │       ├───────────────┤   │
                        └───────────────┘       │ id            │   │
                                                │ listing_id    │   │
                                                │ user_id       │◀──┘
                                                │ rating        │
                                                │ comment       │
                                                │ ...           │
                                                └───────────────┘
```

#### Schema Definitions for New Models

1. **Listing**
   ```ruby
   create_table "listings", force: :cascade do |t|
     t.string "title", null: false
     t.text "description"
     t.decimal "price", precision: 10, scale: 2
     t.references "user", null: false, foreign_key: { to_table: "spree_users" }
     t.references "listable", polymorphic: true, null: false
     t.string "status", default: "draft"
     t.boolean "featured", default: false
     t.datetime "published_at"
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["status"], name: "index_listings_on_status"
     t.index ["featured"], name: "index_listings_on_featured"
   end
   ```

2. **Property**
   ```ruby
   create_table "properties", force: :cascade do |t|
     t.references "listing", null: false, foreign_key: true
     t.string "property_type", null: false  # apartment, house, condo, etc.
     t.string "listing_type", null: false   # rent, sale
     t.integer "bedrooms"
     t.integer "bathrooms"
     t.decimal "area", precision: 10, scale: 2
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
     t.index ["property_type"], name: "index_properties_on_property_type"
     t.index ["listing_type"], name: "index_properties_on_listing_type"
     t.index ["bedrooms"], name: "index_properties_on_bedrooms"
     t.index ["bathrooms"], name: "index_properties_on_bathrooms"
     t.index ["city"], name: "index_properties_on_city"
     t.index ["latitude", "longitude"], name: "index_properties_on_coordinates"
   end
   ```

3. **Service**
   ```ruby
   create_table "services", force: :cascade do |t|
     t.references "listing", null: false, foreign_key: true
     t.references "category", null: false, foreign_key: true
     t.string "pricing_model", null: false  # hourly, fixed, etc.
     t.decimal "price", precision: 10, scale: 2
     t.integer "duration_minutes"
     t.text "service_area"
     t.boolean "remote_available", default: false
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["pricing_model"], name: "index_services_on_pricing_model"
     t.index ["category_id"], name: "index_services_on_category_id"
   end
   ```

4. **ServiceCategory**
   ```ruby
   create_table "service_categories", force: :cascade do |t|
     t.string "name", null: false
     t.text "description"
     t.string "icon"
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["name"], name: "index_service_categories_on_name", unique: true
   end
   ```

5. **Amenity**
   ```ruby
   create_table "amenities", force: :cascade do |t|
     t.string "name", null: false
     t.string "icon"
     t.string "amenity_type"  # property or service
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["name"], name: "index_amenities_on_name", unique: true
   end
   ```

6. **PropertyAmenity** (Join Table)
   ```ruby
   create_table "property_amenities", force: :cascade do |t|
     t.references "property", null: false, foreign_key: true
     t.references "amenity", null: false, foreign_key: true
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["property_id", "amenity_id"], name: "index_property_amenities_on_property_id_and_amenity_id", unique: true
   end
   ```

7. **Booking**
   ```ruby
   create_table "bookings", force: :cascade do |t|
     t.references "listing", null: false, foreign_key: true
     t.references "user", null: false, foreign_key: { to_table: "spree_users" }
     t.string "status", default: "pending"  # pending, confirmed, cancelled, completed
     t.datetime "start_date", null: false
     t.datetime "end_date"
     t.decimal "price", precision: 10, scale: 2
     t.text "notes"
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["status"], name: "index_bookings_on_status"
   end
   ```

8. **Message**
   ```ruby
   create_table "messages", force: :cascade do |t|
     t.references "booking", null: false, foreign_key: true
     t.references "sender", null: false, foreign_key: { to_table: "spree_users" }
     t.text "content", null: false
     t.boolean "read", default: false
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
   end
   ```

9. **Review**
   ```ruby
   create_table "reviews", force: :cascade do |t|
     t.references "listing", null: false, foreign_key: true
     t.references "user", null: false, foreign_key: { to_table: "spree_users" }
     t.integer "rating", null: false
     t.text "comment"
     t.boolean "approved", default: false
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.index ["approved"], name: "index_reviews_on_approved"
   end
   ```

### Spree Commerce Customization

#### Model Extensions

1. **Spree::User Extension**
   ```ruby
   # app/models/spree/user_decorator.rb
   module Spree
     module UserDecorator
       def self.prepended(base)
         base.has_many :listings, dependent: :destroy
         base.has_many :bookings, dependent: :destroy
         base.has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
         base.has_many :reviews, dependent: :destroy
       end

       def property_owner?
         listings.joins(:property).exists?
       end

       def service_provider?
         listings.joins(:service).exists?
       end
     end
   end

   Spree::User.prepend Spree::UserDecorator
   ```

2. **Spree::Product Integration**

   While properties and services will have their own models, we'll leverage Spree's product system for certain features:

   ```ruby
   # app/models/listing_decorator.rb
   module ListingDecorator
     def to_spree_product
       product = Spree::Product.find_or_initialize_by(name: title)
       product.description = description
       product.price = price
       product.shipping_category = Spree::ShippingCategory.find_or_create_by(name: 'Default')
       product.available_on = published_at

       # Set product properties based on listing type
       if listable_type == 'Property'
         property = listable
         product.product_properties.build(
           property: Spree::Property.find_or_create_by(name: 'property_type'),
           value: property.property_type
         )
         product.product_properties.build(
           property: Spree::Property.find_or_create_by(name: 'bedrooms'),
           value: property.bedrooms.to_s
         )
         # Add more properties as needed
       elsif listable_type == 'Service'
         service = listable
         product.product_properties.build(
           property: Spree::Property.find_or_create_by(name: 'service_category'),
           value: service.category.name
         )
         product.product_properties.build(
           property: Spree::Property.find_or_create_by(name: 'pricing_model'),
           value: service.pricing_model
         )
         # Add more properties as needed
       end

       product.save
       product
     end
   end

   Listing.prepend ListingDecorator
   ```

#### Controller Overrides

1. **Listings Controller**
   ```ruby
   # app/controllers/listings_controller.rb
   class ListingsController < ApplicationController
     before_action :authenticate_spree_user!, except: [:index, :show]
     before_action :set_listing, only: [:show, :edit, :update, :destroy]

     def index
       @listings = Listing.published.includes(:listable)

       # Apply filters
       @listings = @listings.where(listable_type: params[:type]) if params[:type].present?

       if params[:property_type].present? && params[:type] == 'Property'
         @listings = @listings.joins(:property).where(properties: { property_type: params[:property_type] })
       end

       if params[:service_category].present? && params[:type] == 'Service'
         @listings = @listings.joins(:service).where(services: { category_id: params[:service_category] })
       end

       # More filters...

       @listings = @listings.page(params[:page]).per(24)
     end

     def show
       @related_listings = Listing.published.where(listable_type: @listing.listable_type)
                                 .where.not(id: @listing.id).limit(4)
     end

     def new
       @listing = current_spree_user.listings.new
       @listing.build_property if params[:type] == 'property'
       @listing.build_service if params[:type] == 'service'
     end

     # More actions...

     private

     def set_listing
       @listing = Listing.find(params[:id])
     end

     def listing_params
       params.require(:listing).permit(
         :title, :description, :price, :status,
         property_attributes: [:property_type, :listing_type, :bedrooms, :bathrooms, :area, :address, :city, :state, :postal_code, :country, :furnished, :available_from, amenity_ids: []],
         service_attributes: [:category_id, :pricing_model, :price, :duration_minutes, :service_area, :remote_available]
       )
     end
   end
   ```

2. **Spree Admin Extension**
   ```ruby
   # app/controllers/spree/admin/listings_controller.rb
   module Spree
     module Admin
       class ListingsController < ResourceController
         before_action :load_data, except: [:index]

         def index
           @listings = Listing.all.page(params[:page]).per(Spree::Config[:admin_products_per_page])
         end

         # More actions...

         private

         def load_data
           @users = Spree::User.all
           @property_types = Property.distinct.pluck(:property_type)
           @service_categories = ServiceCategory.all
         end
       end
     end
   end
   ```

#### View Customizations

1. **Property Listing Detail Page**
   ```erb
   <!-- app/views/listings/show.html.erb (for property) -->
   <div class="property-detail">
     <div class="property-images">
       <% @listing.images.each do |image| %>
         <%= image_tag image, class: 'property-image' %>
       <% end %>
     </div>

     <div class="property-info">
       <h1><%= @listing.title %></h1>
       <p class="price"><%= number_to_currency(@listing.price) %> <%= @listing.listable.listing_type == 'rent' ? '/month' : '' %></p>

       <div class="property-details">
         <div class="detail-item">
           <i class="icon-bed"></i>
           <span><%= @listing.listable.bedrooms %> Bedrooms</span>
         </div>
         <div class="detail-item">
           <i class="icon-bath"></i>
           <span><%= @listing.listable.bathrooms %> Bathrooms</span>
         </div>
         <div class="detail-item">
           <i class="icon-area"></i>
           <span><%= @listing.listable.area %> sq.ft.</span>
         </div>
       </div>

       <div class="property-description">
         <%= @listing.description %>
       </div>

       <div class="property-amenities">
         <h3>Amenities</h3>
         <ul>
           <% @listing.listable.amenities.each do |amenity| %>
             <li><i class="<%= amenity.icon %>"></i> <%= amenity.name %></li>
           <% end %>
         </ul>
       </div>

       <div class="property-location">
         <h3>Location</h3>
         <p><%= @listing.listable.address %>, <%= @listing.listable.city %>, <%= @listing.listable.state %> <%= @listing.listable.postal_code %></p>
         <div id="map" data-latitude="<%= @listing.listable.latitude %>" data-longitude="<%= @listing.listable.longitude %>"></div>
       </div>

       <div class="property-contact">
         <h3>Contact <%= @listing.user.full_name %></h3>
         <%= form_with url: messages_path, local: true do |f| %>
           <%= f.hidden_field :listing_id, value: @listing.id %>
           <%= f.text_area :content, placeholder: "I'm interested in this property..." %>
           <%= f.submit "Send Message", class: "btn btn-primary" %>
         <% end %>
       </div>
     </div>
   </div>
   ```

2. **Service Listing Detail Page**
   ```erb
   <!-- app/views/listings/show.html.erb (for service) -->
   <div class="service-detail">
     <div class="service-images">
       <% @listing.images.each do |image| %>
         <%= image_tag image, class: 'service-image' %>
       <% end %>
     </div>

     <div class="service-info">
       <h1><%= @listing.title %></h1>
       <p class="price"><%= number_to_currency(@listing.price) %> <%= @listing.listable.pricing_model == 'hourly' ? '/hour' : '' %></p>

       <div class="service-category">
         <span class="badge"><%= @listing.listable.category.name %></span>
       </div>

       <div class="service-description">
         <%= @listing.description %>
       </div>

       <div class="service-details">
         <h3>Service Details</h3>
         <ul>
           <li><strong>Pricing:</strong> <%= @listing.listable.pricing_model.titleize %></li>
           <% if @listing.listable.duration_minutes.present? %>
             <li><strong>Duration:</strong> <%= @listing.listable.duration_minutes / 60 %> hours</li>
           <% end %>
           <li><strong>Service Area:</strong> <%= @listing.listable.service_area %></li>
           <li><strong>Remote Available:</strong> <%= @listing.listable.remote_available ? 'Yes' : 'No' %></li>
         </ul>
       </div>

       <div class="service-booking">
         <h3>Book this Service</h3>
         <%= form_with model: Booking.new, local: true do |f| %>
           <%= f.hidden_field :listing_id, value: @listing.id %>
           <%= f.date_field :start_date %>
           <%= f.time_field :start_time %>
           <%= f.text_area :notes, placeholder: "Any special requirements..." %>
           <%= f.submit "Book Now", class: "btn btn-primary" %>
         <% end %>
       </div>

       <div class="service-provider">
         <h3>About the Provider</h3>
         <div class="provider-info">
           <%= image_tag @listing.user.avatar if @listing.user.avatar.attached? %>
           <div>
             <h4><%= @listing.user.full_name %></h4>
             <p>Member since <%= @listing.user.created_at.strftime("%B %Y") %></p>
             <p><%= @listing.user.listings.count %> listings</p>
           </div>
         </div>
       </div>
     </div>
   </div>
   ```

3. **Search and Filter Interface**
   ```erb
   <!-- app/views/listings/index.html.erb -->
   <div class="listings-container">
     <div class="filters-sidebar">
       <%= form_with url: listings_path, method: :get, local: true do |f| %>
         <div class="filter-section">
           <h3>Listing Type</h3>
           <%= f.select :type, [['All', ''], ['Properties', 'Property'], ['Services', 'Service']], { selected: params[:type] }, { class: 'form-control', onchange: 'this.form.submit()' } %>
         </div>

         <% if params[:type] == 'Property' || params[:type].blank? %>
           <div class="filter-section">
             <h3>Property Type</h3>
             <%= f.select :property_type, [['All', ''], ['Apartment', 'apartment'], ['House', 'house'], ['Condo', 'condo']], { selected: params[:property_type] }, { class: 'form-control' } %>
           </div>

           <div class="filter-section">
             <h3>Listing For</h3>
             <%= f.select :listing_type, [['All', ''], ['Rent', 'rent'], ['Sale', 'sale']], { selected: params[:listing_type] }, { class: 'form-control' } %>
           </div>

           <div class="filter-section">
             <h3>Bedrooms</h3>
             <%= f.select :bedrooms, [['Any', ''], ['1+', 1], ['2+', 2], ['3+', 3], ['4+', 4]], { selected: params[:bedrooms] }, { class: 'form-control' } %>
           </div>

           <div class="filter-section">
             <h3>Bathrooms</h3>
             <%= f.select :bathrooms, [['Any', ''], ['1+', 1], ['2+', 2], ['3+', 3]], { selected: params[:bathrooms] }, { class: 'form-control' } %>
           </div>

           <div class="filter-section">
             <h3>Price Range</h3>
             <div class="price-range">
               <%= f.number_field :min_price, placeholder: 'Min', class: 'form-control' %>
               <span>to</span>
               <%= f.number_field :max_price, placeholder: 'Max', class: 'form-control' %>
             </div>
           </div>
         <% end %>

         <% if params[:type] == 'Service' || params[:type].blank? %>
           <div class="filter-section">
             <h3>Service Category</h3>
             <%= f.collection_select :service_category, ServiceCategory.all, :id, :name, { include_blank: 'All Categories' }, { class: 'form-control' } %>
           </div>

           <div class="filter-section">
             <h3>Pricing Model</h3>
             <%= f.select :pricing_model, [['All', ''], ['Hourly', 'hourly'], ['Fixed', 'fixed']], { selected: params[:pricing_model] }, { class: 'form-control' } %>
           </div>
         <% end %>

         <div class="filter-section">
           <h3>Location</h3>
           <%= f.text_field :location, placeholder: 'City, State, or Zip', class: 'form-control' %>
         </div>

         <%= f.submit "Apply Filters", class: "btn btn-primary" %>
       <% end %>
     </div>

     <div class="listings-results">
       <div class="listings-header">
         <h2><%= @listings.total_count %> Results</h2>
         <div class="sort-options">
           Sort by:
           <%= link_to "Newest", listings_path(request.parameters.merge(sort: 'newest')), class: params[:sort] == 'newest' ? 'active' : '' %>
           <%= link_to "Price: Low to High", listings_path(request.parameters.merge(sort: 'price_asc')), class: params[:sort] == 'price_asc' ? 'active' : '' %>
           <%= link_to "Price: High to Low", listings_path(request.parameters.merge(sort: 'price_desc')), class: params[:sort] == 'price_desc' ? 'active' : '' %>
         </div>
       </div>

       <div class="listings-grid">
         <% @listings.each do |listing| %>
           <div class="listing-card">
             <%= link_to listing_path(listing) do %>
               <div class="listing-image">
                 <%= image_tag listing.images.first if listing.images.attached? %>
                 <div class="listing-badge"><%= listing.listable_type %></div>
               </div>

               <div class="listing-details">
                 <h3><%= listing.title %></h3>
                 <p class="listing-price"><%= number_to_currency(listing.price) %></p>

                 <% if listing.listable_type == 'Property' %>
                   <div class="property-features">
                     <span><%= listing.listable.bedrooms %> bd</span>
                     <span><%= listing.listable.bathrooms %> ba</span>
                     <span><%= listing.listable.area %> sqft</span>
                   </div>
                   <p class="listing-location"><%= listing.listable.city %>, <%= listing.listable.state %></p>
                 <% else %>
                   <p class="service-category"><%= listing.listable.category.name %></p>
                   <p class="service-pricing"><%= listing.listable.pricing_model.titleize %> pricing</p>
                 <% end %>
               </div>
             <% end %>
           </div>
         <% end %>
       </div>

       <div class="pagination">
         <%= paginate @listings %>
       </div>
     </div>
   </div>
   ```

### API Design

#### RESTful API Endpoints

1. **Listings API**

   ```
   GET    /api/v2/storefront/listings                # List all listings with filtering
   GET    /api/v2/storefront/listings/:id            # Get a specific listing
   POST   /api/v2/storefront/listings                # Create a new listing (authenticated)
   PUT    /api/v2/storefront/listings/:id            # Update a listing (authenticated)
   DELETE /api/v2/storefront/listings/:id            # Delete a listing (authenticated)
   ```

2. **Properties API**

   ```
   GET    /api/v2/storefront/properties              # List all properties with filtering
   GET    /api/v2/storefront/properties/:id          # Get a specific property
   ```

3. **Services API**

   ```
   GET    /api/v2/storefront/services                # List all services with filtering
   GET    /api/v2/storefront/services/:id            # Get a specific service
   ```

4. **Bookings API**

   ```
   GET    /api/v2/storefront/bookings                # List user's bookings (authenticated)
   GET    /api/v2/storefront/bookings/:id            # Get a specific booking (authenticated)
   POST   /api/v2/storefront/bookings                # Create a new booking (authenticated)
   PUT    /api/v2/storefront/bookings/:id/status     # Update booking status (authenticated)
   ```

5. **Messages API**

   ```
   GET    /api/v2/storefront/bookings/:id/messages   # Get messages for a booking (authenticated)
   POST   /api/v2/storefront/bookings/:id/messages   # Send a message (authenticated)
   PUT    /api/v2/storefront/messages/:id/read       # Mark message as read (authenticated)
   ```

6. **Reviews API**

   ```
   GET    /api/v2/storefront/listings/:id/reviews    # Get reviews for a listing
   POST   /api/v2/storefront/listings/:id/reviews    # Create a review (authenticated)
   ```

7. **Search API**

   ```
   GET    /api/v2/storefront/search                  # Search listings with advanced filtering
   ```

#### Example Request/Response Payloads

1. **Property Listing Request**

   ```json
   {
     "listing": {
       "title": "Modern Downtown Apartment",
       "description": "Beautiful 2-bedroom apartment in the heart of downtown",
       "price": 1500.00,
       "status": "published",
       "listable_type": "Property",
       "property_attributes": {
         "property_type": "apartment",
         "listing_type": "rent",
         "bedrooms": 2,
         "bathrooms": 1,
         "area": 850.00,
         "address": "123 Main St",
         "city": "San Francisco",
         "state": "CA",
         "postal_code": "94105",
         "country": "USA",
         "furnished": true,
         "available_from": "2023-08-01",
         "amenity_ids": [1, 3, 5]
       }
     }
   }
   ```

   Example: POST request to create a new property listing

2. **Property Listing Response**

   ```json
   // GET /api/v2/storefront/listings/1
   {
     "data": {
       "id": "1",
       "type": "listing",
       "attributes": {
         "title": "Modern Downtown Apartment",
         "description": "Beautiful 2-bedroom apartment in the heart of downtown",
         "price": "1500.00",
         "status": "published",
         "featured": false,
         "published_at": "2023-07-15T10:30:00Z",
         "created_at": "2023-07-15T10:30:00Z",
         "updated_at": "2023-07-15T10:30:00Z"
       },
       "relationships": {
         "user": {
           "data": {
             "id": "101",
             "type": "user"
           }
         },
         "listable": {
           "data": {
             "id": "1",
             "type": "property"
           }
         },
         "images": {
           "data": [
             {
               "id": "1",
               "type": "image"
             },
             {
               "id": "2",
               "type": "image"
             }
           ]
         }
       }
     },
     "included": [
       {
         "id": "1",
         "type": "property",
         "attributes": {
           "property_type": "apartment",
           "listing_type": "rent",
           "bedrooms": 2,
           "bathrooms": 1,
           "area": "850.00",
           "address": "123 Main St",
           "city": "San Francisco",
           "state": "CA",
           "postal_code": "94105",
           "country": "USA",
           "latitude": "37.789458",
           "longitude": "-122.394516",
           "furnished": true,
           "available_from": "2023-08-01"
         },
         "relationships": {
           "amenities": {
             "data": [
               {
                 "id": "1",
                 "type": "amenity"
               },
               {
                 "id": "3",
                 "type": "amenity"
               },
               {
                 "id": "5",
                 "type": "amenity"
               }
             ]
           }
         }
       },
       {
         "id": "101",
         "type": "user",
         "attributes": {
           "email": "owner@example.com",
           "full_name": "John Smith",
           "created_at": "2023-01-15T00:00:00Z"
         }
       },
       {
         "id": "1",
         "type": "amenity",
         "attributes": {
           "name": "WiFi",
           "icon": "wifi"
         }
       },
       {
         "id": "3",
         "type": "amenity",
         "attributes": {
           "name": "Air Conditioning",
           "icon": "snowflake"
         }
       },
       {
         "id": "5",
         "type": "amenity",
         "attributes": {
           "name": "Parking",
           "icon": "car"
         }
       }
     ]
   }
   ```

3. **Search Request**

   ```
   GET /api/v2/storefront/search?type=Property&property_type=apartment&listing_type=rent&min_price=1000&max_price=2000&bedrooms=2&bathrooms=1&city=San%20Francisco&amenities[]=1&amenities[]=5
   ```

4. **Booking Request**

   ```json
   // POST /api/v2/storefront/bookings
   {
     "booking": {
       "listing_id": 1,
       "start_date": "2023-08-15T14:00:00Z",
       "end_date": "2023-08-15T16:00:00Z",
       "notes": "I'd like to view this apartment"
     }
   }
   ```

### Search and Filtering Implementation

The application will use Elasticsearch for advanced search capabilities, especially for geospatial searches and complex filtering:

```ruby
# app/models/listing.rb
class Listing < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :user, class_name: 'Spree::User'
  belongs_to :listable, polymorphic: true
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :title, :price, presence: true

  scope :published, -> { where(status: 'published') }
  scope :featured, -> { where(featured: true) }

  # Elasticsearch settings
  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :title, type: 'text', analyzer: 'english'
      indexes :description, type: 'text', analyzer: 'english'
      indexes :price, type: 'float'
      indexes :status, type: 'keyword'
      indexes :featured, type: 'boolean'
      indexes :published_at, type: 'date'
      indexes :created_at, type: 'date'

      indexes :listable_type, type: 'keyword'

      # Property-specific fields
      indexes :property do
        indexes :property_type, type: 'keyword'
        indexes :listing_type, type: 'keyword'
        indexes :bedrooms, type: 'integer'
        indexes :bathrooms, type: 'integer'
        indexes :area, type: 'float'
        indexes :city, type: 'keyword'
        indexes :state, type: 'keyword'
        indexes :postal_code, type: 'keyword'
        indexes :country, type: 'keyword'
        indexes :furnished, type: 'boolean'
        indexes :available_from, type: 'date'
        indexes :location, type: 'geo_point'
        indexes :amenities, type: 'keyword'
      end

      # Service-specific fields
      indexes :service do
        indexes :category_id, type: 'integer'
        indexes :category_name, type: 'keyword'
        indexes :pricing_model, type: 'keyword'
        indexes :duration_minutes, type: 'integer'
        indexes :remote_available, type: 'boolean'
      end

      # User fields
      indexes :user do
        indexes :id, type: 'integer'
        indexes :email, type: 'keyword'
        indexes :full_name, type: 'text'
      end
    end
  end

  # Elasticsearch document
  def as_indexed_json(options = {})
    as_json(
      only: [:id, :title, :description, :price, :status, :featured, :published_at, :created_at, :listable_type],
      include: {
        user: { only: [:id, :email], methods: [:full_name] }
      }
    ).merge(
      property: property_json,
      service: service_json
    )
  end

  private

  def property_json
    return {} unless listable_type == 'Property'

    property = listable
    {
      property_type: property.property_type,
      listing_type: property.listing_type,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      area: property.area,
      city: property.city,
      state: property.state,
      postal_code: property.postal_code,
      country: property.country,
      furnished: property.furnished,
      available_from: property.available_from,
      location: { lat: property.latitude, lon: property.longitude },
      amenities: property.amenities.pluck(:name)
    }
  end

  def service_json
    return {} unless listable_type == 'Service'

    service = listable
    {
      category_id: service.category_id,
      category_name: service.category.name,
      pricing_model: service.pricing_model,
      duration_minutes: service.duration_minutes,
      remote_available: service.remote_available
    }
  end
end
```

The search controller will handle complex queries:

```ruby
# app/controllers/api/v2/storefront/search_controller.rb
module Api
  module V2
    module Storefront
      class SearchController < BaseController
        def index
          @search = search_listings
          render_serialized_payload { serialize_search_results(@search) }
        end

        private

        def search_listings
          query = {
            bool: {
              must: must_conditions,
              filter: filter_conditions
            }
          }

          Listing.search(
            query: query,
            sort: sort_options,
            page: params[:page] || 1,
            per_page: params[:per_page] || 24
          )
        end

        def must_conditions
          conditions = []

          # Text search
          if params[:q].present?
            conditions << {
              multi_match: {
                query: params[:q],
                fields: ['title^3', 'description', 'property.city^2', 'service.category_name^2']
              }
            }
          end

          # Only published listings
          conditions << { term: { status: 'published' } }

          conditions
        end

        def filter_conditions
          conditions = []

          # Listing type filter
          if params[:type].present?
            conditions << { term: { listable_type: params[:type] } }
          end

          # Property filters
          if params[:property_type].present?
            conditions << { term: { 'property.property_type': params[:property_type] } }
          end

          if params[:listing_type].present?
            conditions << { term: { 'property.listing_type': params[:listing_type] } }
          end

          if params[:bedrooms].present?
            conditions << { range: { 'property.bedrooms': { gte: params[:bedrooms].to_i } } }
          end

          if params[:bathrooms].present?
            conditions << { range: { 'property.bathrooms': { gte: params[:bathrooms].to_i } } }
          end

          # Price range
          if params[:min_price].present? || params[:max_price].present?
            price_range = {}
            price_range[:gte] = params[:min_price].to_f if params[:min_price].present?
            price_range[:lte] = params[:max_price].to_f if params[:max_price].present?
            conditions << { range: { price: price_range } }
          end

          # Location search
          if params[:lat].present? && params[:lon].present? && params[:distance].present?
            conditions << {
              geo_distance: {
                distance: "#{params[:distance]}km",
                'property.location': {
                  lat: params[:lat].to_f,
                  lon: params[:lon].to_f
                }
              }
            }
          end

          # Service filters
          if params[:service_category].present?
            conditions << { term: { 'service.category_id': params[:service_category].to_i } }
          end

          if params[:pricing_model].present?
            conditions << { term: { 'service.pricing_model': params[:pricing_model] } }
          end

          # Amenities filter
          if params[:amenities].present?
            params[:amenities].each do |amenity|
              conditions << { term: { 'property.amenities': amenity } }
            end
          end

          conditions
        end

        def sort_options
          case params[:sort]
          when 'price_asc'
            [{ price: { order: 'asc' } }]
          when 'price_desc'
            [{ price: { order: 'desc' } }]
          else
            [{ published_at: { order: 'desc' } }]
          end
        end

        def serialize_search_results(results)
          Spree::V2::Storefront::ListingSerializer.new(
            results.results,
            include: [:user, :listable, :images]
          ).serializable_hash
        end
      end
    end
  end
end
```

### Integration with External Services

#### Payment Gateway Integration (Stripe)

```ruby
# app/models/booking.rb
class Booking < ApplicationRecord
  belongs_to :listing
  belongs_to :user, class_name: 'Spree::User'
  has_many :messages, dependent: :destroy

  validates :start_date, :status, presence: true

  enum status: { pending: 0, confirmed: 1, cancelled: 2, completed: 3 }

  after_create :create_payment_intent, if: :requires_payment?

  def requires_payment?
    listing.price.present? && listing.price > 0
  end

  def create_payment_intent
    return unless requires_payment?

    intent = Stripe::PaymentIntent.create(
      amount: (listing.price * 100).to_i, # Stripe uses cents
      currency: 'usd',
      customer: user.stripe_customer_id,
      metadata: {
        booking_id: id,
        listing_id: listing.id,
        listing_title: listing.title
      }
    )

    update(stripe_payment_intent_id: intent.id)
  end

  def confirm_payment
    return unless stripe_payment_intent_id.present?

    intent = Stripe::PaymentIntent.retrieve(stripe_payment_intent_id)

    if intent.status == 'succeeded'
      update(status: :confirmed, payment_status: 'paid')
      # Notify listing owner
      BookingMailer.booking_confirmed(self).deliver_later
    else
      update(payment_status: intent.status)
    end
  end
end
```

#### Google Maps Integration

```javascript
// app/javascript/controllers/map_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    latitude: Number,
    longitude: Number,
    zoom: { type: Number, default: 15 },
    markers: Array
  }

  connect() {
    if (typeof google === 'undefined') {
      this.loadGoogleMapsAPI()
    } else {
      this.initializeMap()
    }
  }

  loadGoogleMapsAPI() {
    const script = document.createElement('script')
    script.src = `https://maps.googleapis.com/maps/api/js?key=${process.env.GOOGLE_MAPS_API_KEY}&callback=initMap`
    script.async = true
    script.defer = true
    window.initMap = this.initializeMap.bind(this)
    document.head.appendChild(script)
  }

  initializeMap() {
    const mapOptions = {
      center: { lat: this.latitudeValue, lng: this.longitudeValue },
      zoom: this.zoomValue,
      mapTypeControl: false,
      streetViewControl: false
    }

    const map = new google.maps.Map(this.element, mapOptions)

    // Add marker for the property location
    new google.maps.Marker({
      position: { lat: this.latitudeValue, lng: this.longitudeValue },
      map: map,
      animation: google.maps.Animation.DROP
    })

    // Add additional markers if provided
    if (this.hasMarkersValue) {
      this.markersValue.forEach(marker => {
        new google.maps.Marker({
          position: { lat: marker.lat, lng: marker.lng },
          map: map,
          title: marker.title,
          icon: marker.icon
        })
      })
    }
  }
}
```

This architecture provides a comprehensive plan for extending a Spree Commerce application to support a multi-vendor marketplace for property and service listings. The design leverages Spree's existing e-commerce capabilities while adding custom models and functionality specific to property and service listings.
