require 'test/unit'
require './models'

class GoGameTest < Test::Unit::TestCase
  def setup
    REDIS.flushdb
  end

  def games_match(expected, actual)
    assert_equal expected.id, actual.id
    assert_equal expected.state, actual.state
  end

  def test_save_load
    g1 = GoGame.new(1)
    g1.set(2, 3, 'w')

    g2 = GoGame.new(2)
    g2.set(4, 13, 'b')

    assert_equal 0, GoGame.all_ids.size

    g1.save
    g2.save

    games_match(g1, GoGame.load(1))
    games_match(g2, GoGame.load(2))
    assert_equal 2, GoGame.size
  end

  def test_game_set_overwrites
    g = GoGame.new(1)
    g.set(2, 3, GoGame::Colors::White)
    g.set(2, 3, GoGame::Colors::White)

    assert_equal [{ 'x' => 2, 'y' => 3, 'color' => GoGame::Colors::White }], g.state
  end

  def test_game_delete
    g = GoGame.new(1)

    g.save
    assert_equal GoGame.size, 1
    g.delete
    assert_equal GoGame.size, 0
  end

  def test_game_unset
    g = GoGame.new(1)
    g.set(5, 9, GoGame::Colors::Black)
    g.unset(5, 9)
    assert_equal [], g.state
  end
end
