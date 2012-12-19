require 'helper'

class ArduinoTest < Vault::TestCase
  include Vault::Test::EnvironmentHelpers

  # if we set the delay to zero it won't get set
  def test_heartbeat_uses_heartbeat_delay
    set_env 'HEARTBEAT_DELAY', '0'
    Arduino.up?.must_equal false
    Arduino.heartbeat
    Arduino.up?.must_equal false
  end

  # Arduino.heartbeat should make Arduino.up? true
  def test_heartbeat_sets_up_to_true
    Arduino.up?.must_equal false
    Arduino.heartbeat
    Arduino.up?.must_equal true
  end
end
