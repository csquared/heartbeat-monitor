require './env'

loop do
  sleep ENV['MONITOR_INTERVAL'].to_i
  unless Arduino.up?
    Mail.deliver do
      from 'heartbeat-monitor'
      to   ENV['MONITOR_EMAIL']
      subject 'Outage Lights Down'
      body    Time.now.to_s
    end
  end
end
