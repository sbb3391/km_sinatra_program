class ChangeProposalDateColumn < ActiveRecord::Migration[5.2]
  def change
    change_column :proposals, :created_date, :datetime
  end

end
