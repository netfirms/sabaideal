# frozen_string_literal: true

# This migration comes from komplex (originally 20240701000011)
class CreateKomplexReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :komplex_reviews do |t|
      t.references :listing, null: false, foreign_key: { to_table: :komplex_listings }
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.integer :rating, null: false
      t.text :comment
      t.boolean :approved, default: false

      t.timestamps
    end

    add_index :komplex_reviews, :approved
  end
end