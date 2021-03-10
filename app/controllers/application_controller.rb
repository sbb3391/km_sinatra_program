require_relative '../../config/environment'

class ApplicationController < Sinatra::Base
  
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions unless test?
    set :session_secret, "secret"
    use Rack::Flash
  end

  get '/' do

    erb :'login.html'
  end

  get '/home' do 

    @user = User.find(session[:id])

    erb :'/home.html'
  end

  post '/login' do 

    @user = User.find_by(username: params[:username])
  
    if @user == nil
      redirect to '/'
    elsif !!@user.authenticate(params[:password])
      session[:id] = @user.authenticate(params[:password]).id
      redirect to '/proposals'
    else
      redirect to '/proposals'
    end
  end

  get '/signup' do 

    erb :'/signup.html'
  end

  post '/signup' do
    if params[:username] == "" || params[:password] == ""
      redirect to '/signup'
    elsif User.find_by(username: params[:username])
      flash[:message] = "That username already exists. Please select another username."
      redirect to '/signup'
    else
      @user = User.create(params)
      session[:id] = @user.id

      10.times do 
        Account.create(
          user_id: @user.id,
          name: Faker::Company.unique.name,
          address: Faker::Address.street_address,
          city: Faker::Address.city,
          state: Faker::Address.state,
          zip: Faker::Address.zip_code
        )
      end

      redirect to '/proposals'
    end
  end

  get '/logout' do

    if session[:id] != nil
      session.delete(:id)
      redirect to '/'
    else
      redirect to '/'
    end

  end

  not_found do
    status 404
    erb :not_found
  end

  helpers do
    def current_user
        @user = User.find(session[:id]) if session[:id]
    end
    
    def logged_in?
        !!session[:id]
    end

    def proposal_belongs_to_user?
      current_user.proposals.include?(Proposal.find_by_id(params[:id]))  if params[:id]
    end

    def current_proposal
      @proposal = Proposal.find_by_id(params[:id]) if params[:id]
    end
    
    def user_accounts 
      @accounts = current_user.accounts
    end

    def engines
      current_proposal.line_items.where(product_id: Product.all.where(category: "Engine"))
    end
    
    def validate_user_and_proposal
      redirect_to_login if !logged_in?
      current_user
      current_proposal
      user_accounts
      invalid_proposal_id if !proposal_belongs_to_user? && params[:id] != nil 
    end

    def total_proposal_price
      total_price = 0

      @proposal.line_items.each do |line_item|
        total_price += line_item.extended_price if line_item.extended_price != nil
      end
  
      @total_price = total_price
    end


    def parse_timestamp( time )
      time = time.in_time_zone('Eastern Time (US & Canada)')
      time.strftime("%B %d, %Y, %l:%M%P")
    end

    def categories
      @categories = ["Engine", "Install", "Paper Supply", "Output", "Print Controller Options", "Misc."]
    end

    def update_proposal_name
      x = params[:name] if params[:name]

      current_proposal.update(name: x) if x != "" && current_proposal.name != x
    end

    def create_proposal_pricing_options
      ppi = current_proposal.proposal_pricing_options
      
      ppi.destroy_all
      
      #create new pricing options
      params[:create_proposal_pricing_options][:pricing_option_ids].each do |option|
        ppi.create(pricing_option_id: option.to_i)
      end
    end

    def proposal_line_items_crud
      li = current_proposal.line_items
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
    end

    def update_cost_per_impressions
      li = current_proposal.line_items
      params[:clicks].each do |k,v|
        v[0] = nil if v[0] == ""
        v[1] = nil if v[1] == ""
        
        li.find(k.to_i).update(color_cpi: v[0], mono_cpi: v[1])
      end
    end

    def edit_line_item_service_options
      li = current_proposal.line_items
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
    end

    def edit_show_summary
      current_proposal.update(show_summary: params[:show_summary])
    end
   
    def remove_selected_units
      li = current_proposal.line_items
      #remove units if checkbox is on
      if params[:remove_item] != nil
        params[:remove_item].each do |k,v|
          li.where(product_id: Product.all.where(km_equipment: k)).destroy_all
        end
      end
    end

    def are_any_included?(arr1, arr2)
      arr1.any? {|i| arr2.include?(i)}
    end

    def proposal_validation
      cannot_configure = []
      configuration_smell = []
      ids = []

      engines.each do |engine|
        km_part_ids = current_proposal.line_items.where(product_id: Product.all.where(km_equipment: Product.find(engine.product_id).km_equipment)).map {|li| Product.find(li.product_id).km_product_id}

        # if km_part_ids.include?("A8FRWY1") && !km_part_ids.include?("A9PJWY1")
        #   cannot_configure << "#{Product.find(engine.product_id).km_equipment} - A9PJWY1 is required with the IQ-501."
        #   interface_kit = "A9PJWY1"
        #   ids << interface_kit
        # end

        # if km_part_ids.include?("A8FRWY1") && (!km_part_ids.include?("A9CEWY1") || !km_part_ids.include?("A9CEWY2"))
        #   cannot_configure << "#{Product.find(engine.product_id).km_equipment} - RU-518 is required with the IQ-501."
        #   iq = ["A9CEWY1", "A9CEWY2"]
        #   iq.each {|i| ids << i}
        # end

        if !are_any_included?(["AC4GWY1", "AC4HWY1", "AC4JWY1", "A95VWY1", "A8K4WY2", "A03WWY", "A55CWY3", "A0U4WY3", "A55CWY2"], km_part_ids)
          cannot_configure << "#{Product.find(engine.product_id).km_equipment} - Please include a paper feeding unit (PF/LU unit)."
          paper_feed = ["AC4GWY1", "AC4HWY1", "AC4JWY1", "A95VWY1", "A8K4WY2", "A03WWY", "A55CWY3", "A0U4WY3", "A55CWY2"]
          paper_feed.each {|i| ids << i}
        end

        if !are_any_included?(["A043WY", "AC8WWY1", "A4F3WY6", "A93JWY2", "AC8WWY1", "AAUUWY1", "A043WY1", "A4F3WY5", "A4F3W15"], km_part_ids)
          cannot_configure << "#{Product.find(engine.product_id).km_equipment} - Please include a paper output unit (FS/OT unit)."
          paper_output = ["A043WY", "AC8WWY1", "A4F3WY6", "A93JWY2", "AC8WWY1", "AAUUWY1", "A043WY1", "A4F3WY5", "A4F3W15"]
          paper_output.each {|i| ids << i}
        end

        if !are_any_included?(["ACAYWY1", "ACVAWY1", "ACN1WY1", "A9F5WY5", "A9F8WY2", "A9VKWY3", "A9U10Y1", "ACAXWY1", "ACC0WY1", "ACME0Y1", "ACMG0Y1"], km_part_ids)
          cannot_configure << "#{Product.find(engine.product_id).km_equipment} - Please include an image controller (IC unit)."
          image_controller = ["ACAYWY1", "ACVAWY1", "ACN1WY1", "A9F5WY5", "A9F8WY2", "A9VKWY3", "A9U10Y1", "ACAXWY1", "ACC0WY1", "ACME0Y1", "ACMG0Y1"]
          image_controller.each {|i| ids << i}
        end

        if are_any_included?(["A0H2WY3", "AAPKWY1", "A65UWY2", "AC3TWY1"], km_part_ids) && (!km_part_ids.include?("A9CEWY2") && !km_part_ids.include?("A9CEWY1"))
          cannot_configure << "#{Product.find(engine.product_id).km_equipment} - Configuration must include RU-518."
          ru_518 = ["A0H2WY3", "AAPKWY1", "A65UWY2", "AC3TWY1"]
          ru_518.each {|i| ids << i}
        end

      end


      if !cannot_configure.empty?
        flash[:messages] = cannot_configure
        flash[:ids] = ids
        redirect to "/proposals/#{session[:proposal_id]}/edit"
      elsif !configuration_smell.empty?
        flash[:message] = configuration_smell
        redirect to "/proposals/#{session[:proposal_id]}"
      else
        redirect to "/proposals/#{session[:proposal_id]}"
      end
    end

    def power_supplies_for_default
      x = Product.import('./csv/power supply.csv')

      x.map {|a| a.to_s.chop}
    end

    def delivery_install_for_default
      x = Product.import('./csv/delivery and install.csv')
      x.map {|a| a.to_s.chop}
    end

    
    def flash_enter_proposal_name
      binding.pry
      flash[:message] = "You must enter a proposal name"
      redirect to '/proposals/new'
    end

    def new_proposal_validation
      errors = []
      errors << "your proposal must have a name" if params[:name] == ""
      errors << "your proposal must have at least one pricing option" if params[:create_proposal_pricing_options] == nil
      errors << "your proposal must have at least one model" if params[:proposal][:product_ids] == nil

      if !errors.empty? 
        flash[:messages] = errors
        redirect to '/proposals/new'
      end
    end
  end


  private 

  def redirect_to_login
    flash[:message] = "You must be logged in to complete this request. Please Log in."
    flash[:alert_type] = "danger"
    redirect "/"
  end

  def invalid_proposal_id
    flash[:message] = "You do not have permissions to view or edit this proposal"
    redirect '/proposals'
  end

  def invalid_proposal_edit
    flash[:message] = "Invalid Edit. You are not allowed to edit this proposal."

end
end






