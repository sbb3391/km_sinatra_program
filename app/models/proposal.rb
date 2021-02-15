class Proposal < ActiveRecord::Base
  has_many :line_items
  belongs_to :account
  has_many :products, through: :line_items

end