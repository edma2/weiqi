require 'sinatra'
require 'haml'
require './models'

get '/' do
  @ids = GoGame.all_ids
  haml :index
end

get '/:id' do
  g = GoGame.load(params[:id])
  g ? g.to_json : 404
end

get '/:id/:color/play' do
  id = params[:id].to_i
  @g = GoGame.load(id) || GoGame.create(id)
  @color = params[:color]
  haml :play
end

post '/:id/:color/move' do
  return 400 if params[:x].nil? || params[:y].nil?

  x = params[:x].to_i
  y = params[:y].to_i
  color = params[:color].to_i

  if x <= 19 && y <= 19 && [0, 1].include?(color)
    g = GoGame.load(params[:id])
    return 404 unless g
    stone = Stone.new(x, y, color)
    g.play(stone)
    g.save
    200
  else
    400
  end
end
