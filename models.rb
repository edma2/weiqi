require 'set'
require 'json'
require './init/redis'

# [
#   { x: 5,
#     y: 8,
#     type: w },
#   { x: 14,
#     y: 3,
#     type: b },
#   ...
# ]
class GoGame
  attr_reader :state, :id

  def initialize(id, state = [])
    @id = id
    @state = state
  end

  def key
    @id.to_s
  end

  def to_json
    JSON.generate(@state)
  end

  def set(x, y, type)
    s = @state.to_set
    s.add({ 'x' => x, 'y' => y, 'type' => type})
    s.to_a
  end

  def self.load(id)
    key = id.to_s
    json = REDIS.get(key)
    if json.nil?
      nil
    else
      GoGame.new(id, JSON.parse(json))
    end
  end

  def save
    REDIS.set(key, to_json)
  end
end
