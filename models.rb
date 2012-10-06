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
  attr_reader :state, :id

  module Colors
    Black = 0
    White = 1
  end

  class << self
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

  def initialize(id, state = [])
    @id = id
    @state = state
  end

  def key
    GoGame.key(@id)
  end

  def to_json
    JSON.generate(@state)
  end

  def set(x, y, color)
    s = @state.to_set
    s.add({ 'x' => x, 'y' => y, 'color' => color })
    @state = s.to_a
  end

  def save
    REDIS.set(key, to_json)
  end

  def delete
    REDIS.del(key)
  end
end
