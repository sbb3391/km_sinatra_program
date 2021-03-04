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

    redirect_to_login if !logged_in?

    @engines = Product.all.where(category: "Engine")
    @accounts = Account.all

    erb :'proposals/new.html'

  end

  get '/proposals/:id' do 

    #If no user is logged in, return to the login screen. If a user is logged in, but an invalid proposal id was passed, return to /proposals
    redirect_to_login if !logged_in?
    current_user
    invalid_proposal_id if !current_user.proposals.include?(Proposal.find_by_id(params[:id]))
    
    @proposal = Proposal.find_by_id(params[:id])
    @categories = ["Engine", "Install", "Paper Supply", "Output", "Print Controller Options", "Misc."]
    
    total_price = 0

    @proposal.line_items.each do |line_item|
      total_price += line_item.extended_price if line_item.extended_price != nil
    end

    @total_price = total_price
    
    erb :'proposals/show.html'
  end


  get '/proposals/:id/line_items/new' do

    redirect_to_login if !logged_in?
    current_user
    invalid_proposal_id if !current_user.proposals.include?(Proposal.find_by_id(params[:id]))

    @proposal = Proposal.find(params[:id])
    @categories = ["Engine", "Install", "Paper Supply", "Output", "Print Controller Options", "Misc."]

    erb :'/proposals/new_line_items.html'
  end

  get '/proposals/:id/edit' do

    redirect_to_login if !logged_in?
    current_user
    invalid_proposal_id if !current_user.proposals.include?(Proposal.find_by_id(params[:id]))

    @proposal = Proposal.find(params[:id])
    @categories = ["Engine", "Install", "Paper Supply", "Output", "Print Controller Options", "Misc."]


    erb :"proposals/edit.html"
  end 

  post '/proposals' do

    account = Account.find(params[:proposal][:account_id])

    if params[:name] == ""
      flash[:message] = "You must enter a proposal name"
      redirect to '/proposals/new'
    end

    #create a new proposal for the selected account
    @proposal = account.proposals.create(account_id: params[:proposal][:account_id].to_i)

    #add proposal name
    @proposal.update(name: params[:name])
    
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
    proposal = Proposal.find(params[:id])
    li = proposal.line_items
    ppi = proposal.proposal_pricing_options

    #update name
    x = params[:name]

    if x != "" && proposal.name != x
      proposal.update(name: x)
    end

    #create or delete proposal pricing options
    #destroy existing proposal pricing options
    
    ppi.destroy_all

    #create new pricing options
    params[:create_proposal_pricing_options][:pricing_option_ids].each do |option|
      ppi.create(pricing_option_id: option.to_i)
    end

    
    #create, update, or destroy proposal line items
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

    #update cost per impression data for engine models
    params[:clicks].each do |k,v|
      v[0] = nil if v[0] == ""
      v[1] = nil if v[1] == ""
      
      li.find(k.to_i).update(color_cpi: v[0], mono_cpi: v[1])
    end

    #edit line_item service options
    #update service_lock
    params[:lock].each do |k,v|
      if v.to_i.is_a?(Integer) && v.to_i != 0
        if li.find(k.to_i).service_lock_years != v.to_i
          li.find(k.to_i).update(service_lock_years: v.to_i)
        end
      end
    end

    #update one_click_maximum
    params[:one_click].each do |k,v|
      if li.find(k.to_i).one_click_maximum != v
        li.find(k.to_i).update(one_click_maximum: v)
      end
    end

    #update 'updated_at'
    Proposal.find(params[:id]).update(updated_at: Time.now)

    #handle 'show_summary' option
    Proposal.find(params[:id]).update(show_summary: params[:show_summary])

    #remove units if checkbox is on
    if params[:remove_item] != nil
      params[:remove_item].each do |k,v|
        li.where(product_id: Product.all.where(km_equipment: k)).destroy_all
      end
    end

    redirect to "/proposals/#{params[:id]}"
  end

  get '/proposals/:id/preview' do 

    redirect_to_login if !logged_in?

    current_user
    @proposal = Proposal.find(params[:id])
    
    total_price = 0

    @proposal.line_items.each do |line_item|
      total_price += line_item.extended_price
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

      File.rename(li_for_image.image.path, File.join(Dir.pwd, "public", "uploads", "#{hash[hash_key]}.jpg"))
    end

    redirect to "/proposals/#{params[:id]}/preview"
  end

  post '/proposals/:id/delete' do
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