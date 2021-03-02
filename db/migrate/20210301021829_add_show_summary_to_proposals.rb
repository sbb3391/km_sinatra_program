class AddShowSummaryToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :proposals, :show_summary, :string
  end
end
