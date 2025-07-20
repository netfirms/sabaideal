class CreateKomplexAdvertisements < ActiveRecord::Migration[8.0]
  def change
    create_table :komplex_advertisements do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :placement, null: false
      t.string :ad_type, null: false
      t.references :merchant, null: false, foreign_key: { to_table: :komplex_merchants }
      t.references :listing, foreign_key: { to_table: :komplex_listings }
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.decimal :cost, precision: 10, scale: 2, default: 0.0, null: false
      t.string :status, default: 'pending', null: false

      t.timestamps
    end
  end
end
