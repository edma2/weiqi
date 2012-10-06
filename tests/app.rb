require 'test/unit'
require 'rack/test'
require './app'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    REDIS.flushdb
  end

  def test_get_root
    get '/'
    assert last_response.body.include?('hello world!')
  end
end
