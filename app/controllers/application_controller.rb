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
  end

end

