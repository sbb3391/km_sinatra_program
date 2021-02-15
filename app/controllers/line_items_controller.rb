require 'pry'
require_relative '../../config/environment'

class LineItemsController < Sinatra::Base
  
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
  end

  
  
end