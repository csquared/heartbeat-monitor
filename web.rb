require './env'

BASIC_AUTH = lambda do |username, password|
  if [username, password] == [ENV['API_USERNAME'], ENV['API_PASSWORD']]
    true
  else
    $stdout.puts 'Auth Fail'
    false
  end
end


class Frontend < Sinatra::Base
  configure :production do
    require 'sinatra-google-auth'
    register Sinatra::GoogleAuth
    use Sinatra::GoogleAuth::Middleware
    use Rack::SslEnforcer unless ENV['SSL_OFF']
  end

  get '/' do
    @color = Arduino.up? ? 'green' : 'red'
    erb :index
  end
end

#Deprecated: It auto-sets the heartbeat when you get the status.
class Api < Sinatra::Base
  use Rack::Auth::Basic, "Restricted Area", &BASIC_AUTH

  post '/' do
    Arduino.heartbeat
    'ok'
  end
end

class Status < Sinatra::Base
  use Rack::Auth::Basic, "Restricted Area", &BASIC_AUTH

  get '*' do
    red = true
    # Let's us trigger a "red" response by setting a config var for testing
    if ENV['FIREDRILL']
      $stdout.puts "firedrill=true "
    else
      # Assume we're up!
      Arduino.heartbeat
      begin
        # Connect to status
        url = ENV['STATUS_URL']
        result = Excon.get(url).body
        $stdout.puts "url=#{url} result=#{result}"
        red = (result.empty? || JSON.parse(result)["status"].values.include?('red'))
      rescue Exception => e
        puts "Error connecting to status #{e.message}"
      end
    end
    status = red ? 'red' : 'green'
    $stdout.puts "status=#{status}"
    status
  end
end

StatusMonitor = Rack::Builder.new do
  map '/' do
    run Frontend
  end

  map '/auth' do
    run Frontend
  end

  # Todo: Deprecate
  map '/heartbeat' do
    run Api
  end

  map '/status' do
    run Status
  end
end
