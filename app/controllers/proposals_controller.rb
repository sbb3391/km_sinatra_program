class ProposalsController < ApplicationController
 
    # configure do
    #   set :public_folder, 'public'
    #   set :views, 'app/views'
    #   enable :sessions unless test?
    #   set :session_secret, "secret"
    #   register Sinatra::Flash
    # end

  get '/proposals' do 
    current_user

    redirect_to_login if !logged_in?

    erb :'proposals/index.html'
  end

  get '/proposals/new' do
    validate_user_and_proposal

    @engines = Product.all.where(category: "Engine")

    erb :'proposals/new.html'

  end

  get '/proposals/:id' do 

    #If no user is logged in, return to the login screen. If a user is logged in, but an invalid proposal id was passed, return to /proposals
    validate_user_and_proposal
    categories
    
    total_proposal_price
    
    erb :'proposals/show.html'
  end


  get '/proposals/:id/line_items/new' do

   validate_user_and_proposal
   categories

    erb :'/proposals/new_line_items.html'
  end

  get '/proposals/:id/edit' do
    validate_user_and_proposal
    categories

    session[:proposal_id] = params[:id]

    erb :"proposals/edit.html"
  end 

  post '/proposals' do

    account = Account.find(params[:proposal][:account_id])

    new_proposal_validation

    #create a new proposal for the selected account
    @proposal = account.proposals.create(account_id: params[:proposal][:account_id].to_i)

    #add proposal name
    @proposal.update(name: params[:name])
    
    #give the new proposal line items, based on the selections
    params[:proposal][:product_ids].each do |product|
      @proposal.line_items.create(product_id: product.to_i, quantity: 1)

      new_models_accessories = Product.all.where(km_equipment: Product.find(@proposal.line_items.last.product_id).km_equipment).map {|i| i.km_product_id}
      new_model_power_supplies = new_models_accessories.select {|acc| power_supplies_for_default.include?(acc)}
      new_model_power_supplies.each do |i|
        prod = Product.find_by(km_product_id: i)
        @proposal.line_items.create(product_id: prod.id, quantity: 1)
      end

      new_model_delivery_items = new_models_accessories.select {|acc| delivery_install_for_default.include?(acc)}
      new_model_delivery_items.each do |i|
        p = Product.find_by(km_product_id: i)
        @proposal.line_items.create(product_id: p.id, quantity: 1)
      end
      # # ["ACC2011", "XGPCS20820DKM", "XGPCS15DKM", "7670525509", "7640018097", "7640012602"] 	XGPCS15DKM
    end

    #give the new proposal pricing options, based on the selections
    params[:create_proposal_pricing_options][:pricing_option_ids].each do |option|
      @proposal.proposal_pricing_options.create(pricing_option_id: option)
    end

    redirect to "proposals/#{@proposal.id}/edit"
  end

  patch "/proposals/:id/edit" do
    validate_user_and_proposal
    #logic to make sure a user cannot hack the program by changing the html in chrome inspection tools
    invalid_proposal_edit if params[:id] != session[:proposal_id]

    #update name
    update_proposal_name

    create_proposal_pricing_options

    #create, update, or destroy proposal line items
    proposal_line_items_crud

    update_cost_per_impressions

    edit_line_item_service_options

    Proposal.find(params[:id]).update(updated_at: Time.now)

    edit_show_summary

    remove_selected_units

    #makes sure that there are not mistakes in the configuration so that invalid products are not created
    proposal_validation

    redirect to "/proposals/#{params[:id]}"
  end

  get '/proposals/:id/preview' do 

    redirect_to_login if !logged_in?

    current_user
    @proposal = Proposal.find(params[:id])
    
    total_price = 0

    @proposal.line_items.each do |line_item|
      total_price += line_item.extended_price if line_item.extended_price != nil
    end

    @total_price = total_price

    erb :"/proposals/preview.html"
  end

  post '/proposals/:id/preview' do
    
    proposal = Proposal.find(params[:id])
    
    hash = {}

    proposal.line_items.where(product_id: Product.all.where(category: "Engine")).each do |li|
      hash[:"#{Product.find(li.product_id).km_equipment}"] = []
    end

    
    #get all line items in the proposal that are used to validate photos
    proposal.line_items.where(product_id: Product.all.where(photo_validate: true)).each do |li| 
      hash[:"#{Product.find(li.product_id).km_equipment}"] << Product.find(li.product_id).km_product_id
    end
    
    hash.each do |k,v|
      x = hash[k].map {|x| x}
      hash[k] = x.join.chars.sort.join
    end
    
    hash_key = Product.find(params["photo"].keys.first).km_equipment.to_sym
    
    if hash[hash_key] == ""
      true
    else
      li_for_image = proposal.line_items.find_by(product_id: params["photo"].keys.first)
      li_for_image.image = params["photo"][params["photo"].keys.first]
      li_for_image.save!

      File.rename(li_for_image.image.path, File.join(Dir.pwd, "public", "uploads", "#{hash[hash_key]}.png"))
    end

    redirect to "/proposals/#{params[:id]}/preview"
  end

  post '/proposals/:id/delete' do
    #add logic to make sure user can only delete your own proposal

    proposal = Proposal.find(params[:id])
    proposal.destroy
    redirect to "/proposals"
  end

  get "/proposals/:id/preview.pdf" do
    PDFKit.configure do |config|
    # config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf'
    headers['Content-Type'] = 'application/pdf'
    config.default_options = {
      :page_size => 'A3',
      :load_error_handling => 'skip',
      :load_media_error_handling => "ignore",
      :debug_javascript => true,
      :javascript_delay => "300",
      :print_media_type => true,
      :margin_top => "8mm",
      :margin_bottom => "5mm",
      :footer_spacing => "-8",
     }
   end 
    kit = PDFKit.new("http://localhost:9393/proposals/#{params[:id]}/preview")
    kit.to_pdf
  end

end