require 'pry'
require_relative '../../config/environment'

class ProposalsController < Sinatra::Base
  
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
  end

  get '/proposals/new' do
    @engines = Product.all.where(category: "Engine")
    @accounts = Account.all

    erb :'proposals/new.html'

  end

  get '/proposals/:id' do 
    @proposal = Proposal.find(params[:id])
    @categories = ["Engine", "Install", "Paper Supply", "Output", "Print Controller Options", "Misc."]
    
    total_price = 0

    @proposal.line_items.each do |line_item|
      total_price += line_item.extended_price
    end

    @total_price = total_price
    
    erb :'proposals/show.html'
  end


  get '/proposals/:id/line_items/new' do
    @proposal = Proposal.find(params[:id])
    @categories = ["Engine", "Install", "Paper Supply", "Output", "Print Controller Options", "Misc."]

    erb :'/proposals/new_line_items.html'
  end

  get '/proposals/:id/edit' do
    @proposal = Proposal.find(params[:id])
    @categories = ["Engine", "Install", "Paper Supply", "Output", "Print Controller Options", "Misc."]


    erb :"proposals/edit.html"
  end

  post '/proposals' do
    @proposal = Proposal.create(params[:proposal])

    redirect to "proposals/#{@proposal.id}/line_items/new"
  end

  post "/proposals/:id/line_items" do

    #existing line items in the current proposal
    li = Proposal.find(params[:id]).line_items

    params[:product_id].each do |k,v|
      if v == ""
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