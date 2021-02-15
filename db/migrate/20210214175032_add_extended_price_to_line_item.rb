class AddExtendedPriceToLineItem < ActiveRecord::Migration[5.2]
  def change
    add_column :line_items, :extended_price, :decimal
  end
end
