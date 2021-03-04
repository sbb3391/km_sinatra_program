class User < ActiveRecord::Base
  has_many :accounts, dependent: :destroy
  has_many :proposals, through: :accounts 
  has_many :products, through: :proposals
  accepts_nested_attributes_for :proposals
  has_secure_password



end