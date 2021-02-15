require 'pry'

class Product < ActiveRecord::Base

  has_many :line_items
  has_many :proposals, through: :line_items

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


  def self.import_products_from_csv(file)
    x = self.import(file)
    hashed = x.map {|d| d.to_hash}
    stored_products = Product.all.map {|product| product.id}

    starting_products = Product.all.count

    puts "Currently there are #{starting_products} products."

    hashed.each do |row|
      Product.create(row)
    end
  end      

end