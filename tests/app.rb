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

  def test_post_and_get_games
    post '/game'
    post '/game'
    get '/game'
    assert last_response.body.include?('[0,1]')
  end
end
