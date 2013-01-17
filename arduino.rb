module Arduino
  HEARTBEAT_DEFAULT = 10
  KEY = :heartbeat
  extend self

  def up?
    !! REDIS.get(KEY)
  end

  def down!
    REDIS.del(KEY)
  end

  def heartbeat
    $stdout.puts "heartbeat #{Time.now.to_s}"
    REDIS.set    KEY, true
    REDIS.expire KEY, (ENV['HEARTBEAT_DELAY'] || HEARTBEAT_DEFAULT).to_i
  end

  alias_method :up!, :heartbeat
end
