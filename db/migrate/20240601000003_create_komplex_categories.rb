class CreateKomplexCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :komplex_categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :icon
      t.references :parent, foreign_key: { to_table: :komplex_categories }
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :komplex_categories, :name, unique: true
  end
end