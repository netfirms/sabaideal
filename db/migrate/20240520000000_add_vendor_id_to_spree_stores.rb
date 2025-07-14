# frozen_string_literal: true

class AddVendorIdToSpreeStores < ActiveRecord::Migration[6.1]
  def change
    add_reference :spree_stores, :vendor, foreign_key: { to_table: :komplex_vendors }
  end
end