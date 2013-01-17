require './env'

# log auth failures so i can see if someone's being an asshole
BASIC_AUTH = lambda do |username, password|
  if [username, password] == [ENV['API_USERNAME'], ENV['API_PASSWORD']]
    true
  else
    $stdout.puts 'Auth Fail'
    false
  end
end

# for the people
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

#Deprecated: redundant - we now call Arduino.heartbeat when you get the status.
class Api < Sinatra::Base
  use Rack::Auth::Basic, "Restricted Area", &BASIC_AUTH

  post '/' do
    Arduino.heartbeat
    'ok'
  end
end

# for the machines
class Status < Sinatra::Base
  use Rack::Auth::Basic, "Restricted Area", &BASIC_AUTH

  get '*' do
    red = true
    # Let's us trigger a "red" response by setting a config var for testing
    if ENV['FIREDRILL']
      $stdout.puts "firedrill=true "
    else
      # Assume we're up!
      begin
        # Connect to status
        url = ENV['STATUS_URL']
        response = Excon.get(url)
        body   = response.body
        $stdout.puts "url=#{url} status=#{response.status} response_body=#{body}"
        if response.status == 502 || body.empty?
          $stdout.puts "at=502 override"
          red = false
        else
          red = JSON.parse(body)["status"].values.include?('red')
        end
        Arduino.up!
      rescue Exception => e
        Arduino.down!
        red = false
        $stdout.puts "error=#{e.class} message=#{e.message}"
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
