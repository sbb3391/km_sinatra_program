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
  
  @@photo_parts = [
    "AAMPWY1",
    "A03WWY2",
    "A8K4WY2",
    "A55CWY3",
    "A043WY1",
    "AC8WWY1",
    "A04HWY2",
    "A4F3WY6",
    "A4F4WY1",
    "AAMPWY1",
    "A0U4WY3",
    "A03WWY2",
    "A8K4WY2",
    "AA01WY1",
    "A9CEWY2",
    "A8FRWY1",
    "A04HWY2",
    "A4F3WY6",
    "AC8UW11",
    "A4F4WY1",
    "AC3TWY1",
    "A65UWY2",
    "AAPKWY1",
    "AC4GWY1",
    "AC4HWY1",
    "AC4KWY1",
    "AC4JWY1",
    "A8FRWY1",
    "A9CEWY2",
    "AC8WWY1",
    "AAUUWY1",
    "AAPKWY1",
    "A04HWY2",
    "A4F4WY1",
    "AC3TWY1",
    "A0H2WY3",
    "A65UWY2",
    "A9CEWY1"
  ]

  def self.photo_validation
    x = @@photo_parts.uniq
    x
  end

end