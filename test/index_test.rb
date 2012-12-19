require 'helper'

class IndexTest < Vault::TestCase
  include Rack::Test::Methods
  include Vault::Test::EnvironmentHelpers

  def setup
    super
    REDIS.flushall
    set_env 'API_USERNAME', 'user'
    set_env 'API_PASSWORD', 'password'
  end

  def test_no_hearbeat
    get '/'
    last_response.status.must_equal 200
    last_response.body.must_include 'red'
    last_response.body.wont_include 'green'
  end

  def test_no_hearbeat
    authorize 'user', 'password'
    post 'heartbeat'
    last_response.status.must_equal 200
    get '/'
    last_response.status.must_equal 200
    last_response.body.must_include 'green'
    last_response.body.wont_include 'red'
  end
end
