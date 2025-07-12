# frozen_string_literal: true

class CreateKomplexPromotions < ActiveRecord::Migration[7.0]
  def change
    create_table :komplex_promotions do |t|
      t.string :title, null: false
      t.text :description
      t.string :promotion_type, null: false  # percentage, fixed_amount
      t.decimal :discount_amount, precision: 10, scale: 2, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.references :vendor, foreign_key: { to_table: :komplex_vendors }
      t.references :listing, foreign_key: { to_table: :komplex_listings }
      t.string :code
      t.integer :usage_limit
      t.integer :usage_count, default: 0

      t.timestamps
    end

    add_index :komplex_promotions, :code, unique: true
    add_index :komplex_promotions, [:starts_at, :ends_at], name: "index_komplex_promotions_on_date_range"
  end
end