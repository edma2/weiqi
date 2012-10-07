require 'test/unit'
require './models'

class GoGameTest < Test::Unit::TestCase
  def setup
    REDIS.flushdb
  end

  def test_save_load
    g1 = GoGame.new
    g2 = GoGame.new

    assert_equal 0, GoGame.size

    g1.save
    assert_equal 1, GoGame.next_id
    assert_equal g1.id, GoGame.load(0).id

    g2.save
    assert_equal 2, GoGame.next_id
    assert_equal g2.id, GoGame.load(1).id

    assert_equal 2, GoGame.size
  end

  def test_save_load_save
    g = GoGame.new
    g.save
    g_loaded = GoGame.load(0)
    g_loaded.save
    g_loaded_again = GoGame.load(0)

    assert_equal 1, GoGame.size
    assert_equal 0, g_loaded_again.id
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

  def test_game_set_stone
    g = GoGame.new
    g.set(5, 9, Stone::Colors::BLACK)
    g.save
    g_loaded = GoGame.load(0)

    assert_equal 0, g_loaded.id
    assert_equal 1, g_loaded.stones.size
    assert_equal 5, g_loaded.stones[0].x
    assert_equal 9, g_loaded.stones[0].y
    assert_equal Stone::Colors::BLACK, g_loaded.stones[0].color
  end

  def test_game_unset_stone
    g = GoGame.new
    g.set(5, 9, Stone::Colors::BLACK)
    g.unset(5, 9)
    assert_equal [], g.stones
  end
end
