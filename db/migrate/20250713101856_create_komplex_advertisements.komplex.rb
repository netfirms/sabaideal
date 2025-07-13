# frozen_string_literal: true

# This migration comes from komplex (originally 20240701000008)
class CreateKomplexAdvertisements < ActiveRecord::Migration[7.0]
  def change
    create_table :komplex_advertisements do |t|
      t.string :title, null: false
      t.text :description
      t.string :placement, null: false  # homepage, search_results, category_page
      t.string :ad_type, null: false    # banner, sidebar, featured
      t.references :vendor, null: false, foreign_key: { to_table: :komplex_vendors }
      t.references :listing, foreign_key: { to_table: :komplex_listings }
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.decimal :cost, precision: 10, scale: 2, null: false
      t.string :status, default: "pending"  # pending, active, completed, rejected

      t.timestamps
    end

    add_index :komplex_advertisements, :placement
    add_index :komplex_advertisements, :ad_type
    add_index :komplex_advertisements, :status
    add_index :komplex_advertisements, [:starts_at, :ends_at], name: "index_komplex_advertisements_on_date_range"
  end
end