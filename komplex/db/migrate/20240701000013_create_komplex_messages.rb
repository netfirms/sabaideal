# frozen_string_literal: true

class CreateKomplexMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :komplex_messages do |t|
      t.references :conversation, null: false, foreign_key: { to_table: :komplex_conversations }
      t.references :sender, null: false, foreign_key: { to_table: :spree_users }
      t.text :content, null: false
      t.boolean :read, default: false

      t.timestamps
    end
  end
end