require 'redis'
require 'uri'

url = ENV["REDISTOGO_URL"]
REDIS = if url
  uri = URI.parse(url)
  Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  Redis.new
end
