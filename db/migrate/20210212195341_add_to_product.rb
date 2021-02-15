class AddToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :km_equipment, :string
    add_column :products, :category, :string
  end
end
