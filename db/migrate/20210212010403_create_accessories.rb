class CreateAccessories < ActiveRecord::Migration[5.2]
  def change
    create_table :accessories do |t|
      t.string :product_id
      t.string :name
      t.string :accessory_type
      t.string :description
      t.string :unit_price
    end
  end
end
