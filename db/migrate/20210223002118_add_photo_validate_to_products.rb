class AddPhotoValidateToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :photo_validate, :string
  end
end

