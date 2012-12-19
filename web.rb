require './env'

class Frontend < Sinatra::Base
  if ENV['RACK_ENV'] == 'production'
    require 'sinatra-google-auth'
    register Sinatra::GoogleAuth
    use Sinatra::GoogleAuth::MiddleWare
  end

  get '/' do
    @color = Arduino.up? ? 'green' : 'red'
    erb :index
  end
end

class Api < Sinatra::Base
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    if [username, password] == [ENV['API_USERNAME'], ENV['API_PASSWORD']]
      true
    else
      $stdout.puts 'Auth Fail'
      false
    end
  end

  post '/' do
    Arduino.heartbeat
    $stdout.puts "heartbeat #{Time.now.to_s}"
    'ok'
  end
end

class Status < Sinatra::Base
  get '*' do
    red = true
    # Let's us trigger a "red" response by setting a config var for testing
    if ENV['FIREDRILL']
      $stdout.puts "firedrill=true "
      red = true
    else
      # Connect to status
      begin
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

  map '/heartbeat' do
    run Api
  end

  map '/status' do
    run Status
  end
end

