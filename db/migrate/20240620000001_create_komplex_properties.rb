class CreateKomplexProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :komplex_properties do |t|
      t.string :property_type, null: false
      t.string :listing_type
      t.integer :bedrooms
      t.integer :bathrooms
      t.decimal :area
      t.string :area_unit
      t.string :address

      t.timestamps
    end
  end
end