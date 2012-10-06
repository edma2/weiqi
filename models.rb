require 'set'
require 'json'
require './init/redis'

# [
#   { x: 5,
#     y: 8,
#     color: w },
#   { x: 14,
#     y: 3,
#     color: b },
#   ...
# ]
class GoGame
  attr_reader :id

  module Colors
    Black = 0
    White = 1
  end

  class << self
    def next_id
      size
    end

    def key(id)
      "weiqi-#{id}"
    end

    def all_ids
      REDIS.keys("weiqi-*")
    end

    def size
      all_ids.size
    end

    def load(id)
      json = REDIS.get(key(id))
      if json.nil?
        nil
      else
        GoGame.new(id, JSON.parse(json))
      end
    end
  end

  def initialize(id = nil, state = Set.new)
    @id = id # nil unless saved or fetched from store
    @state = state
  end

  def key
    @id.nil? ? nil : GoGame.key(@id)
  end

  def state
    @state.to_a
  end

  def to_json
    JSON.generate(state)
  end

  def set(x, y, color)
    @state.add({ 'x' => x, 'y' => y, 'color' => color })
  end

  def save
    @id = GoGame.next_id
    REDIS.set(key, to_json)
  end

  def delete
    REDIS.del(key) if key
  end

  def unset(x, y)
    @state.delete_if { |cell| cell['x'] == x && cell['y'] == y }
  end
end
