require 'redis'
require 'uri'

url = ENV["REDISTOGO_URL"] # Heroku specific
REDIS = if url
  uri = URI.parse(url)
  Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  Redis.new
end
