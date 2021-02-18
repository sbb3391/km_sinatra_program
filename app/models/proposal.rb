class Proposal < ActiveRecord::Base
  has_many :line_items
  belongs_to :account
  belongs_to :user
  has_many :products, through: :line_items
  has_many :proposal_pricing_options
  has_many :pricing_options, through: :proposal_pricing_options

end