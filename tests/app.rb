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

  def test_create_game
    assert_nil GoGame.load(0)
    get '/0/0/play'
    assert_not_nil GoGame.load(0)
  end

  def test_get_game
    GoGame.create(0)

    get '/0'
    g = GoGame.from_json(last_response.body)
    assert_equal 0, g.color
    assert_equal [], g.stones
  end

  def test_post_moves
    GoGame.create(0)

    post '/0/0/move?x=4&y=3'
    g = GoGame.load(0)
    assert_equal 1, g.color
    assert_equal 0, g.stones[0].color
    assert_equal 4, g.stones[0].x
    assert_equal 3, g.stones[0].y
  end
end
