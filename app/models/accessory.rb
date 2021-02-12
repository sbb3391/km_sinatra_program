require 'pry'

class Accessory < ActiveRecord::Base

  has_many :joins
  has_many :models, through: :joins

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


  def self.import_accessories_from_csv(file)
    x = self.import(file)
    hashed = x.map {|d| d.to_hash}
    stored_product_ids = Accessory.all.map {|accessory| accessory.product_id}

    starting_product_ids = Accessory.all.count
    starting_joins = Join.all.count

    puts "Currently there are #{starting_product_ids} part numbers and #{starting_joins} joins."

    hashed.each do |row|

      #do nothing if the part number is already stored, and a join already exists between the machine and accessory
      if stored_product_ids.include?(row[:product_id].to_s) && Join.all.where(model_id: Model.all.find_by(name: row[:km_model]).id, accessory_id: Accessory.all.find_by(product_id: row[:product_id]).id) != []
        true
      #Add a join for the machine and accessory if no join exists, but the part number is already stored
      elsif stored_product_ids.include?(row[:product_id].to_s) && Join.all.where(model_id: Model.all.find_by(name: row[:km_model]).id, accessory_id: Accessory.all.find_by(product_id: row[:product_id]).id)  == []
        Join.create(model_id: Model.all.find_by(name: row[:km_model]).id, accessory_id: Accessory.all.find_by(product_id: row[:product_id]).id)
      #If the part number is not stored, add the accessory to the database and create a join for the model and accessory 
      elsif !(stored_product_ids.include?(row[:product_id].to_s))
        x = row[:km_model]
        row.delete(:km_model)
        Accessory.create(row)
        row.store(:km_model, x)


        Join.create(model_id: Model.all.find_by(name: row[:km_model]).id, accessory_id: Accessory.all.find_by(product_id: row[:product_id]).id)

      end

    end

    puts "you added #{Accessory.all.count - starting_product_ids} part numbers and #{Join.all.count - starting_joins} joins."

  end
      

end