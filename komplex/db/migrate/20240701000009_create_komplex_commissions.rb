# frozen_string_literal: true

class CreateKomplexCommissions < ActiveRecord::Migration[7.0]
  def change
    create_table :komplex_commissions do |t|
      t.references :vendor, null: false, foreign_key: { to_table: :komplex_vendors }
      t.references :order, null: false, foreign_key: { to_table: :spree_orders }
      t.references :line_item, foreign_key: { to_table: :spree_line_items }
      t.decimal :vendor_amount, precision: 10, scale: 2, null: false
      t.decimal :commission_amount, precision: 10, scale: 2, null: false
      t.string :status, default: "pending"  # pending, paid, failed
      t.datetime :paid_at

      t.timestamps
    end

    add_index :komplex_commissions, :status
  end
end