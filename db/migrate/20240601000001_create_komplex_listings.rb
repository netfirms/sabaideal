class CreateKomplexListings < ActiveRecord::Migration[8.0]
  def change
    create_table :komplex_listings do |t|
      t.string :title, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.references :merchant, null: false, foreign_key: { to_table: :komplex_merchants }
      t.references :listable, polymorphic: true, null: false
      t.string :status, default: 'draft', null: false
      t.boolean :featured, default: false
      t.datetime :published_at

      t.timestamps
    end

    add_index :komplex_listings, :status
    add_index :komplex_listings, :featured
  end
end