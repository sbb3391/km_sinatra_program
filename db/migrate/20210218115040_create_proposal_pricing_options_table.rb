class CreateProposalPricingOptionsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :proposal_pricing_options do |t|
      t.belongs_to :pricing_option
      t.belongs_to :proposal
    end
  end
end
