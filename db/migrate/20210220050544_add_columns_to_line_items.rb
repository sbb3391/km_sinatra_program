class AddColumnsToLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :line_items, :service_lock_years, :integer
    add_column :line_items, :one_click_maximum, :string
  end
end
