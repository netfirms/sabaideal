class AddLocationDetailsToKomplexProperties < ActiveRecord::Migration[8.0]
  def change
    add_column :komplex_properties, :city, :string
    add_column :komplex_properties, :state, :string
    add_column :komplex_properties, :postal_code, :string
    add_column :komplex_properties, :country, :string
    add_column :komplex_properties, :latitude, :decimal, precision: 10, scale: 6
    add_column :komplex_properties, :longitude, :decimal, precision: 10, scale: 6
    add_column :komplex_properties, :furnished, :boolean, default: false
    add_column :komplex_properties, :available_from, :date
  end
end