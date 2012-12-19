require 'helper'

class HeartBeatTest < Vault::TestCase
  include Rack::Test::Methods
  include Vault::Test::EnvironmentHelpers

  def setup
    super
    REDIS.flushall
    set_env 'API_USERNAME', 'user'
    set_env 'API_PASSWORD', 'password'
  end

  # Test basic auth requried
  def test_basic_auth
    post '/heartbeat'
    last_response.status.must_equal 401
    authorize 'user', 'password'
    post '/heartbeat'
    last_response.status.must_equal 200
  end

  # Test POST to /heartbeat works and sets Arduino.up? to true
  def test_hearbeat_sets_arduino_up
    Arduino.up?.must_equal false
    authorize 'user', 'password'
    post '/heartbeat'
    Arduino.up?.must_equal true
    last_response.status.must_equal 200
  end


  def test_heartbeat_uses_heartbeat_delay
    set_env 'HEARTBEAT_DELAY', '0'
    Arduino.up?.must_equal false
    authorize 'user', 'password'
    post '/heartbeat'
    Arduino.up?.must_equal false
    last_response.status.must_equal 200
  end
end
