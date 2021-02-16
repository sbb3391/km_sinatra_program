require 'pry'
require_relative '../../config/environment'

class AccountsController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions unless test?
    set :session_secret, "secret"
  end
  
  get '/accounts' do
    @user = User.find(session[:id])

    erb :'/accounts/index.html'
  end
end