require 'helper'

class StatusTest < Vault::TestCase
  include Rack::Test::Methods
  include Vault::Test::EnvironmentHelpers

  def setup
    super
    set_env 'STATUS_URL', 'http://example.com'
    set_env 'API_USERNAME', 'user'
    set_env 'API_PASSWORD', 'password'
  end

  # Test basic auth requried
  def test_basic_auth
    assert_output(//, '') { get '/status' }
    last_response.status.must_equal 401
    authorize 'user', 'foo'
    assert_output(/Auth Fail/, '') { get '/status' }
    last_response.status.must_equal 401
    authorize 'user', 'password'
    assert_output(/status/, //) { get '/status' }
    last_response.status.must_equal 200
  end

  # Test that FIREDRILL env var returns 'red'
  def test_firedrill
    set_env 'FIREDRILL', 'true'
    authorize 'user', 'password'
    capture_io do
      get '/status'
    end
    last_response.body.must_equal 'red'
  end

  def test_status_sets_heartbeat
    Excon.stub({method: :get}, {body: {}.to_json, status: 200})
    Arduino.up?.must_equal false
    authorize 'user', 'password'
    capture_io { get '/status' }
    Arduino.up?.must_equal true
  end

  # Test returns body of 'green' when status url returns green body
  def test_status_green_on_green
    status = {'status' => {'development' => 'green', 'production' => 'green'}}
    Excon.stub({method: :get}, {body: status.to_json, status: 200})

    authorize 'user', 'password'
    assert_output(/green/,'') { get '/status' }
    last_response.body.must_equal 'green'
  end

  # Test returns body of 'red' when production is red
  def test_status_red_on_dev_red
    status = {'status' => {'development' => 'red', 'production' => 'green'}}
    Excon.stub({method: :get}, {body: status.to_json, status: 200})

    authorize 'user', 'password'
    assert_output( /red/,'') { get '/status' }
    last_response.body.must_equal 'red'
  end

  # Test returns body of 'red' when development is red
  def test_status_red_on_prod_red
    status = {'status' => {'development' => 'green', 'production' => 'red'}}
    Excon.stub({method: :get}, {body: status.to_json, status: 200})

    authorize 'user', 'password'
    assert_output( /red/,'') { get '/status' }
    last_response.body.must_equal 'red'
  end

end
