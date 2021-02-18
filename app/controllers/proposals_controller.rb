require 'pry'
require_relative '../../config/environment'

class ProposalsController < Sinatra::Base

    configure do
      set :public_folder, 'public'
      set :views, 'app/views'
      enable :sessions unless test?
      set :session_secret, "secret"
      register Sinatra::Flash
    end

  get '/proposals' do 
    @user = User.find(session[:id])

    erb :'proposals/index.html'
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

    account = Account.find(params[:proposal][:account_id])
    
    #create a new proposal for the selected account
    @proposal = account.proposals.create(account_id: params[:proposal][:account_id].to_i)
    
    #give the new proposal line items, based on the selections
    params[:proposal][:product_ids].each do |product|
      @proposal.line_items.create(product_id: product.to_i, quantity: 1)
    end

    #give the new proposal pricing options, based on the selections
    params[:create_proposal_pricing_options][:pricing_option_ids].each do |option|
      @proposal.proposal_pricing_options.create(pricing_option_id: option)
    end

    redirect to "proposals/#{@proposal.id}/edit"
  end

  patch "/proposals/:id/edit" do
    
    #existing line items in the current proposal
    li = Proposal.find(params[:id]).line_items
    ppi = Proposal.find(params[:id]).proposal_pricing_options

    #create or delete proposal pricing options
    #destroy existing proposal pricing options
    
    ppi.destroy_all

    #create new pricing options
    params[:create_proposal_pricing_options][:pricing_option_ids].each do |option|
      ppi.create(pricing_option_id: option.to_i)
    end


    params[:line_item].each do |k,v|
      item = li.find_by(product_id: Product.find(k.to_i))
      #if the value is empty and that line item did not previosly exist, do nothing
      if v == "" && item == nil
        true
      elsif v == "" && item != nil
        item.destroy
      #if a line item already exists for the key being evaluated and the value is greater than 0, update the quantity for line item
      elsif v.to_i > 0 && item != nil
        li.where(product_id: Product.find(k.to_i)).update(quantity: v.to_i, extended_price: Product.find(k.to_i).price.to_f * v.to_i)
      #if a line item already exists for the key being evaluated and the value is less than or equal to zero, destroy that line_item
      elsif v.to_i <= 0 && item != nil
        item.destroy
      #if the value passed in is 0 or a negative number, do nothing
      elsif v.to_i <= 0
        true
      else
        li.create(product_id: k.to_i, quantity: v.to_i, extended_price: Product.find(k.to_i).price.to_f * v.to_i)
      end
    end

    redirect to "/proposals/#{params[:id]}"
  end

  get '/proposals/:id/preview' do 
    @user = User.find(session[:id])
    @proposal = Proposal.find(params[:id])

    erb :"/proposals/preview.html"
  end

end