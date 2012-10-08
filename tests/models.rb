require 'test/unit'
require './models'

class GoGameTest < Test::Unit::TestCase
  def setup
    REDIS.flushdb
  end

  def test_liberty_count
    # ...w.
    # ..bbb
    # wb.w.
    # wwbbb
    # .w.wb
    b = Board.new([Stone.new(3, 0, 1),
                   Stone.new(2, 1, 0),
                   Stone.new(3, 1, 0),
                   Stone.new(4, 1, 0),
                   Stone.new(0, 2, 1),
                   Stone.new(1, 2, 0),
                   Stone.new(3, 2, 1),
                   Stone.new(0, 3, 1),
                   Stone.new(1, 3, 1),
                   Stone.new(2, 3, 0),
                   Stone.new(3, 3, 0),
                   Stone.new(4, 3, 0),
                   Stone.new(1, 4, 1),
                   Stone.new(3, 4, 1),
                   Stone.new(4, 4, 0)])

    assert_equal 2, b.liberty_count(3, 0)
    assert_equal 6, b.liberty_count(2, 1)
    assert_equal 6, b.liberty_count(3, 1)
    assert_equal 6, b.liberty_count(4, 1)
    assert_equal 4, b.liberty_count(0, 2)
    assert_equal 2, b.liberty_count(1, 2)
    assert_equal 2, b.liberty_count(3, 2)
    assert_equal 4, b.liberty_count(0, 3)
    assert_equal 4, b.liberty_count(1, 3)
    assert_equal 6, b.liberty_count(2, 3)
    assert_equal 6, b.liberty_count(3, 3)
    assert_equal 6, b.liberty_count(4, 3)
    assert_equal 4, b.liberty_count(1, 4)
    assert_equal 2, b.liberty_count(3, 4)
    assert_equal 6, b.liberty_count(4, 4)
  end

  def test_play_stone
    # ..w..
    # .wbw.
    # .....
    b = Board.new([Stone.new(3, 4, 1),
                   Stone.new(5, 4, 1),
                   Stone.new(4, 3, 1),
                   Stone.new(4, 4, 0)])
    assert_not_equal nil, b.get(4, 4)
    b.play(Stone.new(4, 5, 1))
    assert_equal nil, b.get(4, 4)
  end

  def test_capture_precedes_suicide
    # ..w..
    # .w.w.
    # .bwb.
    # ..b..
    b = Board.new([Stone.new(3, 4, 1),
                   Stone.new(5, 4, 1),
                   Stone.new(4, 3, 1),
                   Stone.new(4, 5, 1),
                   Stone.new(3, 5, 0),
                   Stone.new(5, 5, 0),
                   Stone.new(4, 6, 0)])
    b.play(Stone.new(4, 4, 0))
    assert_equal nil, b.get(4, 5)
    assert_equal 0, b.get(4, 4).color
  end

  def test_multi_capture
    # ..bb.
    # .bww.
    # ..bb.
    b = Board.new([Stone.new(2, 0, 0),
                   Stone.new(3, 0, 0),
                   Stone.new(1, 1, 0),
                   Stone.new(2, 1, 1),
                   Stone.new(3, 1, 1),
                   Stone.new(2, 2, 0),
                   Stone.new(3, 2, 0)])
    b.play(Stone.new(4, 1, 0))
    assert_equal nil, b.get(2, 1)
    assert_equal nil, b.get(3, 1)
  end

  def test_save_load
    g1 = GoGame.new
    g2 = GoGame.new

    assert_equal 0, GoGame.size
    g1.save(0)
    g2.save(1)

    assert_equal 0, GoGame.load(0).id
    assert_equal 1, GoGame.load(1).id
    assert_equal 2, GoGame.size
  end

  def test_save_load_save
    g = GoGame.create(0)
    g_loaded = GoGame.load(0)
    g_loaded.save
    g_loaded_again = GoGame.load(0)

    assert_equal 1, GoGame.size
    assert_equal 0, g_loaded_again.id
  end

  def test_game_delete
    g = GoGame.new

    g.save(0)
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
end
