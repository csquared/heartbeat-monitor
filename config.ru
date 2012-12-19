require './web'

use Rack::SslEnforcer if ENV['RACK_ENV'] == 'production'
run StatusMonitor::Web
