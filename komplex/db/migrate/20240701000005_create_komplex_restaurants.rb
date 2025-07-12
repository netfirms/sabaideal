# frozen_string_literal: true

class CreateKomplexRestaurants < ActiveRecord::Migration[7.0]
  def change
    create_table :komplex_restaurants do |t|
      t.references :listing, null: false, foreign_key: { to_table: :komplex_listings }
      t.string :cuisine_type
      t.jsonb :menu_items, default: []
      t.jsonb :opening_hours, default: {}
      t.string :address, null: false
      t.string :city, null: false
      t.string :state
      t.string :postal_code
      t.string :country, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.boolean :delivery_available, default: false
      t.boolean :takeout_available, default: false
      t.boolean :reservation_required, default: false

      t.timestamps
    end

    add_index :komplex_restaurants, :cuisine_type
    add_index :komplex_restaurants, :city
    add_index :komplex_restaurants, [:latitude, :longitude], name: "index_komplex_restaurants_on_coordinates"
  end
end