class Proposal < ActiveRecord::Base
  has_many :line_items
  belongs_to :account
  belongs_to :user
  has_many :products, through: :line_items

end