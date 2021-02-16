require 'pry'
require_relative '../../config/environment'

class UsersController < Sinatra::Base

    configure do
      set :public_folder, 'public'
      set :views, 'app/views'
      enable :sessions unless test?
      set :session_secret, "secret"
    end

end