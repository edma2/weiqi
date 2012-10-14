require 'test/unit'
require './tests/helper'
require './models'

class Stone
  def eql?(other)
    x == other.x && y == other.y
  end

  def hash
    [x, y].hash
  end
end

class GoGameTest < Test::Unit::TestCase
  def setup
    REDIS.flushdb
  end

  def test_capture
    b = load_board "
    ...0.$
    ..***$
    0*.0.$
    00***$
    .0.0*$
    "

    assert_not_nil b.get(3, 4)
    b.play!(Stone.new(2, 4, 0))
    b.play!(Stone.new(3, 5, 0))
    assert_nil b.get(3, 4)
  end

  def test_liberty_counts
    b = load_board "
    ..*.$
    .**.$
    ....$
    "

    counts = b.liberty_counts(0)
    assert_equal 6, counts[Stone.new(2, 0, 0)]
    assert_equal 6, counts[Stone.new(1, 1, 0)]
    assert_equal 6, counts[Stone.new(2, 1, 0)]
  end

  def test_illegal_moves
    g = GoGame.new
    assert !g.play(Stone.new(0, 0, 1)) # white went first
    assert g.play(Stone.new(0, 0, 0)) # black legal move
    assert !g.play(Stone.new(1, 0, 0)) # black tried to go again
    assert !g.play(Stone.new(0, 0, 1)) # white tried overwrite
    assert g.play(Stone.new(4, 0, 1)) # white legal move
    assert !g.play(Stone.new(44, 1, 1)) # black out of bounds
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
