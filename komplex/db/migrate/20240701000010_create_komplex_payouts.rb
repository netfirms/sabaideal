# frozen_string_literal: true

class CreateKomplexPayouts < ActiveRecord::Migration[7.0]
  def change
    create_table :komplex_payouts do |t|
      t.references :vendor, null: false, foreign_key: { to_table: :komplex_vendors }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :status, default: "pending"  # pending, processing, completed, failed
      t.string :transaction_id
      t.text :notes
      t.datetime :processed_at

      t.timestamps
    end

    add_index :komplex_payouts, :status
  end
end