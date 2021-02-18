class PricingOption < ActiveRecord::Base
  has_many :proposal_pricing_options
  has_many :proposals, through: :proposal_pricing_options
  
end