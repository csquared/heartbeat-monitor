module Arduino
  HEARTBEAT_DEFAULT = 10
  extend self

  def up?
    !! REDIS.get(:heartbeat)
  end

  def heartbeat
    REDIS.set    :heartbeat, true
    REDIS.expire :heartbeat, (ENV['HEARTBEAT_DELAY'] || HEARTBEAT_DEFAULT).to_i
  end
end
