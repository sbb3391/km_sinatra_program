class Proposal < ActiveRecord::Base
  has_many :units
  belongs_to :account

end