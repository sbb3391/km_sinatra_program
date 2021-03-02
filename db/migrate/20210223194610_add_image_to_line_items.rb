class AddImageToLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :line_items, :image, :string
  end
end
