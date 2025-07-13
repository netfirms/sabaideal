# frozen_string_literal: true

# This migration comes from komplex (originally 20240701000012)
class CreateKomplexConversations < ActiveRecord::Migration[7.0]
  def change
    create_table :komplex_conversations do |t|
      t.references :listing, null: false, foreign_key: { to_table: :komplex_listings }
      t.references :buyer, null: false, foreign_key: { to_table: :spree_users }
      t.references :vendor, null: false, foreign_key: { to_table: :komplex_vendors }
      t.string :status, default: "active"  # active, archived

      t.timestamps
    end

    add_index :komplex_conversations, :status
  end
end