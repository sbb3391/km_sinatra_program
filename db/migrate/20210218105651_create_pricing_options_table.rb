class CreatePricingOptionsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :pricing_options do |t|
      t.string :name
      t.float :lease_rate_factor
    end
  end
end
