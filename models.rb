require 'json'
require './init/redis'

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
