class LineItem < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :model
  

end