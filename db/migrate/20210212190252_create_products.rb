class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :km_product_id
      t.string :description
      t.decimal :price, default: 0.0
    end
  end
end
