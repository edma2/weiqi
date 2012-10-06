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
    g1 = GoGame.new
    g1.set(2, 3, GoGame::Colors::White)

    g2 = GoGame.new
    g2.set(4, 13, GoGame::Colors::White)

    assert_equal 0, GoGame.size

    g1.save
    assert_equal 1, GoGame.next_id
    games_match(g1, GoGame.load(0))
    g2.save
    assert_equal 2, GoGame.next_id
    games_match(g2, GoGame.load(1))

    assert_equal 2, GoGame.size
  end

  def test_save_load_save
    g = GoGame.new
    g.save
    g_loaded = GoGame.load(0)
    g_loaded.set(2, 3, GoGame::Colors::White)
    g_loaded.save
    g_loaded_again = GoGame.load(0)

    assert_equal 1, GoGame.size
    assert_equal 0, g_loaded_again.id
  end

  def test_game_set_overwrites
    g = GoGame.new
    g.set(2, 3, GoGame::Colors::White)
    g.set(2, 3, GoGame::Colors::White)

    assert_equal [{ 'x' => 2, 'y' => 3, 'color' => GoGame::Colors::White }], g.state
  end

  def test_game_delete
    g = GoGame.new

    g.save
    assert_equal GoGame.size, 1
    g.delete
    assert_equal GoGame.size, 0
  end

  def test_game_delete_unsaved
    g = GoGame.new

    assert_equal GoGame.size, 0
    g.delete
    assert_equal GoGame.size, 0
  end

  def test_game_unset
    g = GoGame.new
    g.set(5, 9, GoGame::Colors::Black)
    g.unset(5, 9)
    assert_equal [], g.state
  end
end
