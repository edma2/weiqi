require 'json'
require 'pusher'
require 'set'
require './init/redis'

Pusher.app_id = ENV['PUSHER_APP_ID']
Pusher.key = ENV['PUSHER_KEY']
Pusher.secret = ENV['PUSHER_SECRET']

class Board
  def initialize(stones)
    @grid = (0..19).map { |i| {} }
    stones.each do |stone|
      @grid[stone.x][stone.y] = stone
    end
  end

  # Construct an array of stones from grid.
  def stones
    @grid.map { |column| column.values }.flatten
  end

  # Returns the stone located at intersection (x, y).
  # Return nil if intersection is empty or (x, y) is out of bounds.
  def get(x, y)
    @grid[x][y]
  end

  # Get the adjacent stones of some stone that are the same color
  def children(node)
    adjacent_intersections(node).map do |x, y|
      get(x, y)
    end.delete_if do |neighbor|
      neighbor.nil? || neighbor.color != node.color
    end
  end

  # Visit all nodes connected to node and of the same color.
  def dfs(node, visited=Set.new, &visit)
    visited << node
    visit.call(node)
    children(node).each do |child|
      dfs(child, visited, &visit) unless visited.member?(child)
    end
  end

  # Return an array of adjacent intersections (array of [x, y] pairs)
  def adjacent_intersections(stone)
    x, y = stone.x, stone.y
    [[x-1, y], [x+1, y], [x, y-1], [x, y+1]]
  end

  # Number of empty adjacent intersections. Used to count liberties.
  def empty_adjacent_intersections_count(stone)
    adjacent_intersections(stone).select do |x, y|
      (0..19).include?(x) && (0..19).include?(y) && get(x, y).nil?
    end.size
  end

  # Return a hash mapping stones with specified color to liberty counts.
  def liberty_counts(color)
    counts = {}
    stones.each do |stone|
      next if stone.color != color || counts.has_key?(stone)
      counts.merge!(chain_liberty_counts(stone))
    end
    counts
  end

  # Return counts for a chain starting at stone.
  def chain_liberty_counts(stone)
    counts = {}
    chain = []
    count = 0
    dfs(stone) do |stone|
      count += empty_adjacent_intersections_count(stone)
      chain << stone
    end
    chain.each { |stone| counts[stone] = count }
    counts
  end

  # The opposite color of stone's color.
  def opposite_color(stone)
    stone.color == 0 ? 1 : 0
  end

  # Play a stone, captured pieces are removed.
  # Returns true if play was legal.
  #
  # First opponent pieces are checked for removal, then
  # stones of the same color. This is to ensure enemy stones
  # are captured before self-capture occurs.
  def play!(stone)
    return false unless get(stone.x, stone.y).nil?
    add!(stone)
    [opposite_color(stone), stone.color].each do |color|
      counts = liberty_counts(color)
      counts.each do |stone, count|
        remove!(stone) if count == 0
      end
    end
    true
  end

  # Add or overwrite previous stone.
  def add!(stone)
    @grid[stone.x][stone.y] = stone
  end

  # Remove a stone. No effect if the stone wasn't there.
  def remove!(stone)
    @grid[stone.x].delete(stone.y)
  end

  # Print the board nicely.
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

  # self -> [ { x: 8, y: 9, color: 123}, ... ]
  def to_serializable
    stones.map { |s| s.to_serializable }
  end
end

class Stone
  attr_reader :x, :y, :color

  def initialize(x, y, color)
    @x = x
    @y = y
    @color = color
  end

  # { x: 8, y: 9, color: 123} -> Stone
  def self.from_serializable(h)
    Stone.new(h['x'], h['y'], h['color'])
  end

  # self -> { x: 8, y: 9, color: 123}
  def to_serializable
    { 'x' => x, 'y' => y, 'color' => color }
  end
end

class GoGame
  attr_accessor :id # only set if exists in db
  attr_reader :color

  class << self
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

    def from_json(json)
      hash = JSON.parse(json)
      stones = hash['stones'].map { |h| Stone.from_serializable(h) }
      color = hash['color']
      GoGame.new(color, stones)
    end

    def load(id)
      json = REDIS.get(key(id))
      if json.nil?
        nil
      else
        g = from_json(json)
        g.id = id
        g
      end
    end

    def create(id, color = 0, stones = [])
      g = GoGame.new(color, stones)
      g.save(id)
      g
    end
  end

  def initialize(color = 0, stones = [])
    @color = color
    @board = Board.new(stones)
  end

  def key
    @id.nil? ? nil : GoGame.key(@id)
  end

  def to_json
    JSON.generate(to_serializable)
  end

  def to_serializable
    { 'stones' => @board.to_serializable,
      'color' => @color }
  end

  def stones
    @board.stones
  end

  def play(stone)
    @board.play!(stone)
    @color = (@color == 1) ? 0 : 1
    Pusher["weiqi-#{id}"].trigger('board-state-change', to_json)
  end

  def save(id = @id)
    @id = id
    REDIS.set(key, to_json)
  end

  def delete
    REDIS.del(key) if key
  end
end
