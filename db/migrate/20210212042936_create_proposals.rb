class CreateProposals < ActiveRecord::Migration[5.2]
  def change
    create_table :proposals do |t|
      t.date :proposal_date
      t.belongs_to :account
    end
  end
end
