class Model < ActiveRecord::Base
  has_many :joins
  has_many :accessories, through: :joins

  def self.import(file)
    CSV.read(file, headers: true, :header_converters => :symbol, :converters => :all, quote_empty: true)
  end

  def self.create_from_csv(file)
    x = self.import(file)
    hashed = x.map {|d| d.to_hash}

    hashed.each do |row|
      self.create(row)
    end
    
  end
  
end