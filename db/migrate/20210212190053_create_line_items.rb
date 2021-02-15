class CreateLineItems < ActiveRecord::Migration[5.2]
  def change
    create_table :line_items do |t|
      t.belongs_to :proposal
      t.belongs_to :product
    end
  end
end
