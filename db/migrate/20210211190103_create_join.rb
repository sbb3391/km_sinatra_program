class CreateJoin < ActiveRecord::Migration[5.2]
  def change
    create_table :joins do |t|
      t.belongs_to :model
      t.belongs_to :accessory
    end
  end
end
