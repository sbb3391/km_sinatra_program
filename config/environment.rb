ENV['SINATRA_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])
require 'rack-flash'

def fi_check_migration
  begin
    ActiveRecord::Migration.check_pending!
  rescue ActiveRecord::PendingMigrationError
    raise ActiveRecord::PendingMigrationError.new "Migrations are pending.\nTo resolve this issue, run: \nrake db:migrate SINATRA_ENV=#{ENV['SINATRA_ENV']}"
  end
end

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/test.db"
)

# ActiveRecord::Base.logger = Logger.new(STDOUT)

require_all 'app'

CarrierWave.configure do |config|
  config.root = File.dirname(__FILE__) + "/public"
end

# ENV['SINATRA_ENV'] ||= "development"
# require 'bundler/setup'
# Bundler.require(:default, ENV['SINATRA_ENV'])
# ActiveRecord::Base.establish_connection(
#   :adapter => "sqlite3",
#   :database => "db/#{ENV['SINATRA_ENV']}.sqlite"
# )
# require './app/controllers/application_controller'
# require_all 'app'