# Komplex UML Class Diagram

```mermaid
classDiagram
    class Spree_User {
        +email: string
        +encrypted_password: string
        +has_one vendor
        +has_many reviews
    }
    
    class Vendor {
        +user_id: integer
        +name: string
        +description: text
        +status: string
        +commission_rate: decimal
        +settings: jsonb
        +belongs_to user
        +has_many listings
        +has_many promotions
        +has_many advertisements
        +has_many commissions
        +has_many payouts
        +has_many conversations
        +approve!()
        +reject!()
        +active?()
        +total_sales()
        +pending_payout_amount()
    }
    
    class Listing {
        +vendor_id: integer
        +title: string
        +description: text
        +price: decimal
        +listable_id: integer
        +listable_type: string
        +status: string
        +featured: boolean
        +published_at: datetime
        +belongs_to vendor
        +belongs_to listable
        +has_many reviews
        +has_many promotions
        +has_many advertisements
        +has_many conversations
        +submit_for_approval!()
        +approve!()
        +reject!()
        +archive!()
        +average_rating()
    }
    
    class Property {
        +listing_id: integer
        +property_type: string
        +listing_type: string
        +bedrooms: integer
        +bathrooms: integer
        +area: decimal
        +area_unit: string
        +address: string
        +city: string
        +state: string
        +postal_code: string
        +country: string
        +latitude: decimal
        +longitude: decimal
        +furnished: boolean
        +available_from: date
        +belongs_to listing
    }
    
    class Restaurant {
        +listing_id: integer
        +cuisine_type: string
        +menu_items: jsonb
        +opening_hours: jsonb
        +address: string
        +city: string
        +state: string
        +postal_code: string
        +country: string
        +latitude: decimal
        +longitude: decimal
        +delivery_available: boolean
        +takeout_available: boolean
        +reservation_required: boolean
        +belongs_to listing
    }
    
    class Service {
        +listing_id: integer
        +category_id: integer
        +pricing_model: string
        +price: decimal
        +duration_minutes: integer
        +service_area: text
        +remote_available: boolean
        +belongs_to listing
        +belongs_to category
    }
    
    class Category {
        +name: string
        +description: text
        +icon: string
        +parent_id: integer
        +position: integer
        +has_many services
        +belongs_to parent
        +has_many children
    }
    
    class Promotion {
        +title: string
        +description: text
        +promotion_type: string
        +discount_amount: decimal
        +starts_at: datetime
        +ends_at: datetime
        +vendor_id: integer
        +listing_id: integer
        +code: string
        +usage_limit: integer
        +usage_count: integer
        +belongs_to vendor
        +belongs_to listing
        +active?()
        +apply_to_order()
    }
    
    class Advertisement {
        +title: string
        +description: text
        +placement: string
        +ad_type: string
        +vendor_id: integer
        +listing_id: integer
        +starts_at: datetime
        +ends_at: datetime
        +cost: decimal
        +status: string
        +belongs_to vendor
        +belongs_to listing
        +active?()
    }
    
    class Commission {
        +vendor_id: integer
        +order_id: integer
        +line_item_id: integer
        +vendor_amount: decimal
        +commission_amount: decimal
        +status: string
        +paid_at: datetime
        +belongs_to vendor
        +belongs_to order
        +belongs_to line_item
        +mark_as_paid!()
    }
    
    class Payout {
        +vendor_id: integer
        +amount: decimal
        +status: string
        +transaction_id: string
        +notes: text
        +processed_at: datetime
        +belongs_to vendor
        +process!()
    }
    
    class Review {
        +listing_id: integer
        +user_id: integer
        +rating: integer
        +comment: text
        +approved: boolean
        +belongs_to listing
        +belongs_to user
        +approve!()
    }
    
    Spree_User "1" -- "0..1" Vendor
    Vendor "1" -- "*" Listing
    Listing "1" -- "1" Property
    Listing "1" -- "1" Restaurant
    Listing "1" -- "1" Service
    Service "*" -- "1" Category
    Category "0..1" -- "*" Category
    Vendor "1" -- "*" Promotion
    Listing "1" -- "*" Promotion
    Vendor "1" -- "*" Advertisement
    Listing "1" -- "*" Advertisement
    Vendor "1" -- "*" Commission
    Vendor "1" -- "*" Payout
    Listing "1" -- "*" Review
    Spree_User "1" -- "*" Review
```

This UML class diagram illustrates the relationships between the core models in the Komplex module. The diagram shows the attributes and methods of each class, as well as the associations between them.

## Key Relationships

- A **Spree::User** can have one **Vendor** account
- A **Vendor** can have many **Listings**, **Promotions**, **Advertisements**, **Commissions**, and **Payouts**
- A **Listing** belongs to a **Vendor** and can be one of several types (Property, Restaurant, Service) through a polymorphic association
- **Promotions** and **Advertisements** can be associated with a specific **Vendor** and optionally a specific **Listing**
- **Reviews** are associated with a **Listing** and the **Spree::User** who created them
- **Commissions** track the financial transactions between the platform and **Vendors**
- **Payouts** represent money transferred to **Vendors**

This structure provides a flexible foundation for a multi-vendor marketplace with support for various listing types and marketing features.