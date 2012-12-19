require 'vault-test-tools'
require './web'

class Vault::TestCase
  def app; StatusMonitor; end
end

Excon.defaults[:mock] = true
