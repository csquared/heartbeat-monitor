STDOUT.sync = STDERR.sync = true

require 'bundler'
Bundler.require
require './arduino'

ENV.use SmartEnv::UriProxy

uri = ENV["REDISTOGO_URL"]
if uri
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  REDIS = Redis.new
end

Mail.defaults do
  delivery_method :smtp, {
    :address => 'smtp.sendgrid.net',
    :port => '587',
    :domain => 'heroku.com',
    :user_name => ENV['SENDGRID_USERNAME'],
    :password => ENV['SENDGRID_PASSWORD'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end
