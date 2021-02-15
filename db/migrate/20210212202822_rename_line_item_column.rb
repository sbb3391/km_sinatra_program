class RenameLineItemColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :line_items, :products_id, :product_id
  end
end
