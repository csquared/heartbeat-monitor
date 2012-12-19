require 'helper'

class StatusTest < Vault::TestCase
  include Rack::Test::Methods
  include Vault::Test::EnvironmentHelpers

  # Test that FIREDRILL env var returns 'red'
  def test_firedrill
    set_env 'FIREDRILL', 'true'
    capture_io do
      get '/status'
    end
    last_response.body.must_equal 'red'
  end

  def test_status

  end
end
