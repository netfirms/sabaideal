class AddFeaturedToKomplexListings < ActiveRecord::Migration[8.0]
  def change
    add_column :komplex_listings, :featured, :boolean, default: false
    add_index :komplex_listings, :featured
  end
end