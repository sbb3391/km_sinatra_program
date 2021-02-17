require 'pry'
require_relative '../../config/environment'

class Helpers

  def self.current_user(session)
    User.find(sessions[:id])
  end

  def self.is_logged_in?(session)
    !!session[:id]
  end


end