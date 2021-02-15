require 'pry'
require_relative '../../config/environment'

# accounts
#/accounts - let a user search through all their accounts, each one will be a link to that account's proposals
#/accounts/:id - let a user search through all the proposals for a particular account id
# proposals
#/proposal - let user select from existing models they want to go into the proposal
#/proposal/:id/accessories/edit - all accessories have a qty of 0, user can change the qty
#/proposal/:id/edit - shows the stored value for all quantities, user can edit, also can add models to the proposal
#/proposal/:id/view - lets the user view the completed proposal, can't edit in this screen


class ApplicationController < Sinatra::Base
  
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
  end

  get '/proposals/new' do
    @engines = Product.all.where(category: "Engine")
    @accounts = Account.all

    erb :'create_proposal.html'

  end

  get '/proposals/:id' do 
    @proposal = Proposal.find(params[:id])
    @categories = ["Engine", "Install", "Paper Supply", "Output", "Print Controller Options", "Misc."]
    
    total_price = 0

    @proposal.line_items.each do |line_item|
      total_price += line_item.extended_price
    end

    @total_price = total_price
    
    erb :'show_proposal.html'
  end
  
  get '/proposals/:id/line_items/new' do
   @proposal = Proposal.find(params[:id])
   @categories = ["Engine", "Install", "Paper Supply", "Output", "Print Controller Options", "Misc."]

   erb :'new_line_items.html'
  end

  get '/proposals/:id/line_items/edit' do
    @proposal = Proposal.find(params[:id])
    @categories = ["Engine", "Install", "Paper Supply", "Output", "Print Controller Options", "Misc."]


    erb :'edit_line_items.html'
  end

  post '/' do
    puts "There were #{Proposal.all.count} proposals."
    Proposal.create(account_id: Account.find(params[:account_id]).id)
    
    
    params.each do |k,v|
      if v == "on"
      Proposal.all.last.line_items.create(product_id: k.to_i)
      end

      puts "Now there are #{Proposal.all.count} proposals."

    end
    redirect to "proposals/#{Proposal.all.last.id}/line_items/new"
  end

  post "/proposals/:id/line_items" do

    #existing line items in the current proposal
    li = Proposal.find(params[:id]).line_items

    params.each do |k,v|
      if v == ""
        true
      #We want to disregard all keys that are not equal to a product id
      elsif k == "id" || k == 
        true
      #if a line item already exists for the key being evaluated, update the quantity for line item
      elsif li.where(product_id: Product.find(k.to_i)) != []
        li.where(product_id: Product.find(k.to_i)).update(quantity: v.to_i, extended_price: Product.find(k.to_i).price.to_f * v.to_i)
      else
        li.create(product_id: k.to_i, quantity: v.to_i, extended_price: Product.find(k.to_i).price.to_f * v.to_i)
      end
    end

    redirect to "/proposals/#{params[:id]}"

  end

end

