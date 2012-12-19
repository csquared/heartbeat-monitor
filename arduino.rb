module Arduino
  HEARTBEAT_DEFAULT = 10
  extend self

  def up?
    !! REDIS.get(:heartbeat)
  end

  def heartbeat
    $stdout.puts "heartbeat #{Time.now.to_s}"
    REDIS.set    :heartbeat, true
    REDIS.expire :heartbeat, (ENV['HEARTBEAT_DELAY'] || HEARTBEAT_DEFAULT).to_i
  end
end
