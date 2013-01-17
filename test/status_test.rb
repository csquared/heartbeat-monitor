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
    status = {'status' => {'development' => 'green', 'production' => 'green'}}
    Excon.stub({method: :get}, {body: status.to_json, status: 200})

    assert_output(//, '') { get '/status' }
    last_response.status.must_equal 401
    authorize 'user', 'foo'
    assert_output(/Auth Fail/, '') { get '/status' }
    last_response.status.must_equal 401
    authorize 'user', 'password'
    assert_output(/response_body=/, //) { get '/status' }
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
    status = {'status' => {'development' => 'green', 'production' => 'green'}}
    Excon.stub({method: :get}, {body: status.to_json, status: 200})

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

  # let's not throw the lights when we fuck up
  # Test returns body of 'green' when response is empty
  def test_status_green_on_empty
    Excon.stub({method: :get}, {body: '', status: 200})

    authorize 'user', 'password'
    assert_output( /status=200/,'') { get '/status' }
    last_response.body.must_equal 'green'
  end

  # let's not throw the lights when we fuck up
  # Test returns body of 'green' when we get html
  def test_json_parser_error
    Excon.stub({method: :get}, {body: '<doctype', status: 200})

    authorize 'user', 'password'
    assert_output( /JSON::ParserError/,'') { get '/status' }
    last_response.body.must_equal 'green'
  end

  # let's not throw the lights when we fuck up
  # Test returns body of 'green' when we get a 502
  # because that means they're restarting nginx.
  def test_status_green_on_502
    Excon.stub({method: :get}, {body: '<doctype', status: 502})

    authorize 'user', 'password'
    assert_output( /502 override/,'') { get '/status' }
    last_response.body.must_equal 'green'
  end

  def test_errors_considered_system_down
    Arduino.up!
    Excon.stub({method: :get}, {body: '<doctype', status: 200})

    authorize 'user', 'password'
    capture_io { get '/status' }
    Arduino.up?.must_equal false
  end
end
