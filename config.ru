
require './config/environment'

require "carrierwave"
require "carrierwave/orm/activerecord"
require 'wicked_pdf'


begin
  fi_check_migration
  
  use WickedPdf::Middleware
  use Rack::MethodOverride
  use ProposalsController
  use AccountsController
  run ApplicationController
rescue ActiveRecord::PendingMigrationError => err
  STDERR.puts err
  puts err
  exit 1

end

CarrierWave.configure do |config|
  config.root = File.dirname(__FILE__) + "/public"
end
