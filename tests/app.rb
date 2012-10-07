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

    post '/game/0/add?x=44&y=3&color=0'
    assert_equal 400, last_response.status

    post '/game/0/add?x=4&y=3&color=0'
    assert_equal 200, last_response.status

    get '/game/0'
    h = JSON.parse(last_response.body)
    assert_equal 4, h[0]['x']
    assert_equal 3, h[0]['y']
    assert_equal 0, h[0]['color']
  end

  def test_delete_game
    post '/game'
    post '/game/0/delete'

    assert_equal 0, GoGame.size
  end
end
