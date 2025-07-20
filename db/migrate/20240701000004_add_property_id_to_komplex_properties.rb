class AddPropertyIdToKomplexProperties < ActiveRecord::Migration[8.0]
  def change
    add_reference :komplex_properties, :property, foreign_key: { to_table: :spree_properties }
  end
end