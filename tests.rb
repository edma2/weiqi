require 'test/unit'
require 'rack/test'
require './app'

class GoGameTest < Test::Unit::TestCase
  def app
    Sinatra::Application
  end

  def setup
    REDIS.flushdb
  end

  def games_match(expected, actual)
    assert_equal expected.id, actual.id
    assert_equal expected.state, actual.state
  end

  def test_save_load
    g = GoGame.new(1)
    g.set(2, 3, 'w')
    g.save
    games_match(g, GoGame.load(1))
  end
end
