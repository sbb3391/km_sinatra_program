class User < ActiveRecord::Base
  has_many :accounts
  has_many :proposals, through: :accounts 
  accepts_nested_attributes_for :proposals
  has_secure_password

end