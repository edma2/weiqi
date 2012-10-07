require 'json'
require './init/redis'

class Board
  def initialize(stones)
    @stones = stones
    @grid = (0..19).map { |i| {} }
    stones.each do |stone|
      @grid[stone.x][stone.y] = stone
    end
  end

  # returns nil if out of bounds
  def get(x, y)
    @grid[x][y]
  end

  def in_bounds(x, y)
    (0..19).include?(x) && (0..19).include?(y)
  end

  def neighbors(stone)
    x, y = stone.x, stone.y
    n = []
    n << [x+1, y] if in_bounds(x+1, y)
    n << [x-1, y] if in_bounds(x-1, y)
    n << [x, y+1] if in_bounds(x, y+1)
    n << [x, y-1] if in_bounds(x, y-1)
    n
  end

  # An array of [x, y] pairs representing liberties of the specified stone
  def liberties(stone, visited)
    neighbors(stone).inject([]) do |result, pos|
      x, y = pos
      neighbor = get(x, y)
      if visited.include?([x, y])
        result
      elsif neighbor.nil?
        result + [[x, y]]
      elsif stone.color == neighbor.color
        result + liberties(neighbor, visited + [[stone.x, stone.y]])
      else
        result
      end
    end.uniq
  end

  def delete_stones(stones)
    stones.each do |stone|
      @grid[stone.x][stone.y] = nil
      @stones.delete_if { |s| s == stone }
    end
  end

  def play(stone)
    @stones.push(stone)
    @grid[stone.x][stone.y] = stone
    # Delete opposite color first to enforce capture before self-capture rule.
    to_delete = @stones.select do |s|
      s.color != stone.color && liberty_count(s.x, s.y) == 0
    end
    delete_stones(to_delete)
    to_delete = @stones.select do |s|
      s.color == stone.color && liberty_count(s.x, s.y) == 0
    end
    delete_stones(to_delete)
  end

  def liberty_count(x, y)
    return 0 if get(x, y).nil?
    liberties(get(x, y), []).size
  end

  def pprint
    (0..19).each do |y|
      line = (0..19).map do |x|
        stone = get(x, y)
        if stone.nil?
          '.'
        else
          stone.color == 0 ? 'b' : 'w'
        end
      end.join
      puts line
    end
  end
end

class Stone
  attr_reader :x, :y, :color

  module Colors
    BLACK = 0
    WHITE = 1
  end

  def initialize(x, y, color)
    @x = x
    @y = y
    @color = color
  end

  def self.from_hash(h)
    Stone.new(h['x'], h['y'], h['color'])
  end

  def to_hash
    { 'x' => x, 'y' => y, 'color' => color }
  end

  def to_json
    JSON.generate(to_hash)
  end
end

class GoGame
  attr_reader :id

  class << self
    def next_id
      size
    end

    def key(id)
      "weiqi-#{id}"
    end

    def id_from_key(key)
      key[6..-1].to_i
    end

    def all_ids
      REDIS.keys("weiqi-*").map { |key| id_from_key(key) }
    end

    def size
      all_ids.size
    end

    def load(id)
      json = REDIS.get(key(id))
      if json.nil?
        nil
      else
        stones = JSON.parse(json).map { |h| Stone.from_hash(h) }
        GoGame.new(id, stones)
      end
    end
  end

  def initialize(id = nil, stones = [])
    @id = id # nil unless saved or fetched from store
    @stones = stones
  end

  def key
    @id.nil? ? nil : GoGame.key(@id)
  end

  def stones
    @stones.to_a
  end

  def to_json
    JSON.generate(stones.map { |s| s.to_hash })
  end

  def set(x, y, color)
    @stones.push(Stone.new(x, y, color))
  end

  def save
    @id ||= GoGame.next_id
    REDIS.set(key, to_json)
  end

  def delete
    REDIS.del(key) if key
  end

  def unset(x, y)
    @stones.delete_if { |s| s.x == x && s.y == y }
  end
end
