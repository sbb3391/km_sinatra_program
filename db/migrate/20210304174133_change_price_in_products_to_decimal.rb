class ChangePriceInProductsToDecimal < ActiveRecord::Migration[5.2]
  def change
    change_column :products, :price, :decmial, :scale => 2
  end
end
