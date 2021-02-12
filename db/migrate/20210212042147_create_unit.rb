class CreateUnit < ActiveRecord::Migration[5.2]
  def change
    create_table :units do |t|
      t.belongs_to :model
      t.belongs_to :proposal
    end
  end
end
