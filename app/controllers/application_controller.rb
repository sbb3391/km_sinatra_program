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
      redirect to '/'
    end
  end

  get '/signup' do 

    erb :'/signup.html'
  end

  post '/signup' do
    binding.pry
    if params[:username] == "" || params[:password] == ""
      redirect to '/signup'
    else
      @user = User.create(params)
      session[:id] = @user.id
      redirect to '/home'
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


    def parse_timestamp( time )
        _time = time.in_time_zone('Eastern Time (US & Canada)')
        _time.strftime("%B %d, %Y, %l:%M%P")
    end
end


  private 

  def redirect_to_login
    flash[:message] = "You must be logged in to complete this request. Please Log in."
    flash[:alert_type] = "danger"
    redirect "/"
  end

  def invalid_proposal_id
    flash[:message] = "Invalid Proposal ID"
    redirect '/proposals'
  end
end


