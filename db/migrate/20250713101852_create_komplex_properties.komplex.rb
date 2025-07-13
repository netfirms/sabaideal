# frozen_string_literal: true

# This migration comes from komplex (originally 20240701000004)
class CreateKomplexProperties < ActiveRecord::Migration[7.0]
  def change
    create_table :komplex_properties do |t|
      t.references :listing, null: false, foreign_key: { to_table: :komplex_listings }
      t.string :property_type, null: false  # apartment, house, condo, etc.
      t.string :listing_type, null: false   # rent, sale
      t.integer :bedrooms
      t.integer :bathrooms
      t.decimal :area, precision: 10, scale: 2
      t.string :area_unit, default: "sqm"   # sqm, sqft
      t.string :address, null: false
      t.string :city, null: false
      t.string :state
      t.string :postal_code
      t.string :country, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.boolean :furnished, default: false
      t.date :available_from

      t.timestamps
    end

    add_index :komplex_properties, :property_type
    add_index :komplex_properties, :listing_type
    add_index :komplex_properties, :bedrooms
    add_index :komplex_properties, :bathrooms
    add_index :komplex_properties, :city
    add_index :komplex_properties, [:latitude, :longitude], name: "index_komplex_properties_on_coordinates"
  end
end