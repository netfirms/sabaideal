class CreateKomplexMerchants < ActiveRecord::Migration[8.0]
  def change
    create_table :komplex_merchants do |t|
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.string :name, null: false
      t.text :description
      t.string :status, default: 'pending', null: false
      t.decimal :commission_rate, precision: 5, scale: 2, default: 0.0
      t.jsonb :settings, default: {}

      t.timestamps
    end

    add_index :komplex_merchants, :status
  end
end