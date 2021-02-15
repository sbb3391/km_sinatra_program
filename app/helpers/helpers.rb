require 'pry'
require_relative '../../config/environment'

class Helpers

  def self.current_user(sessions)
    User.find(sessions[:id])
  end

  def self.is_logged_in?(sessions)
    !!sessions[:id]
  end


end