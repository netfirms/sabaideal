class CreateKomplexServices < ActiveRecord::Migration[8.0]
  def change
    # First ensure that komplex_categories table exists
    unless table_exists?(:komplex_categories)
      # If the table doesn't exist, run the migration that creates it
      require_relative '20240601000003_create_komplex_categories'
      CreateKomplexCategories.new.change
    end

    create_table :komplex_services do |t|
      t.references :category, foreign_key: { to_table: :komplex_categories }
      t.string :pricing_model
      t.decimal :price, precision: 10, scale: 2
      t.integer :duration_minutes
      t.string :service_area
      t.boolean :remote_available, default: false

      t.timestamps
    end
  end
end
