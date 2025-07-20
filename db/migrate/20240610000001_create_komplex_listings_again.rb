class CreateKomplexListingsAgain < ActiveRecord::Migration[8.0]
  def change
    unless table_exists?(:komplex_listings)
      create_table :komplex_listings do |t|
        t.string :title, null: false
        t.text :description, null: false
        t.decimal :price, precision: 10, scale: 2, null: false
        t.references :merchant, null: false, foreign_key: { to_table: :komplex_merchants }
        t.string :status, default: 'pending', null: false
        t.string :condition, null: false
        t.string :category, null: false

        t.timestamps
      end
    end
  end
end