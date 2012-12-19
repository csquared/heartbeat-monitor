require 'vault-test-tools'
require './web'

class Vault::TestCase
  def app; StatusMonitor; end

  def setup
    super
    Excon.stubs.clear
    REDIS.flushall
  end
end

Excon.defaults[:mock] = true
