class AddPublishedAtToKomplexListings < ActiveRecord::Migration[8.0]
  def change
    add_column :komplex_listings, :published_at, :datetime
  end
end