class AddListableToKomplexListings < ActiveRecord::Migration[8.0]
  def change
    add_reference :komplex_listings, :listable, polymorphic: true
  end
end