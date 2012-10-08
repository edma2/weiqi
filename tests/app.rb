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

  def test_post_and_get_games
    GoGame.create(0)
    GoGame.create(1)

    get '/game'
    assert last_response.body.include?('[0,1]')

    post '/game/0/1/move?x=44&y=3'
    assert_equal 400, last_response.status

    post '/game/0/1/move?x=4&y=3'
    puts last_response.body
    assert_equal 200, last_response.status

    get '/game/0'
    h = JSON.parse(last_response.body)
    assert_equal 4, h[0]['x']
    assert_equal 3, h[0]['y']
    assert_equal 1, h[0]['color']
  end
end
