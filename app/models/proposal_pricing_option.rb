class ProposalPricingOption < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :pricing_option
end