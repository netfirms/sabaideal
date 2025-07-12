# frozen_string_literal: true

class CreateKomplexServices < ActiveRecord::Migration[7.0]
  def change
    create_table :komplex_services do |t|
      t.references :listing, null: false, foreign_key: { to_table: :komplex_listings }
      t.references :category, null: false, foreign_key: { to_table: :komplex_categories }
      t.string :pricing_model, null: false  # hourly, fixed, etc.
      t.decimal :price, precision: 10, scale: 2
      t.integer :duration_minutes
      t.text :service_area
      t.boolean :remote_available, default: false

      t.timestamps
    end

    add_index :komplex_services, :pricing_model
    add_index :komplex_services, :category_id
  end
end