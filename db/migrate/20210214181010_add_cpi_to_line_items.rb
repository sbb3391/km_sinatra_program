class AddCpiToLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :line_items, :color_cpi, :decimal
    add_column :line_items, :mono_cpi, :decimal
  end
end
