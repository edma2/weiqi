require 'sinatra'
require 'haml'
require './models'

helpers do
  def missing?(params, names)
    names.select { |name| params[name].nil? }.size > 0
  end
end

get '/' do
  'hello world!'
end

get '/game' do
  ids = GoGame.all_ids
  JSON.generate(ids)
end

get '/game/:id' do
  g = GoGame.load(params[:id])
  g ? g.to_json : 404
end

get '/game/:id/:color/play' do
  @g = GoGame.load(params[:id])
  return 404 if @g.nil?

  haml :play
end

post '/game' do
  g = GoGame.new
  g.save
  200
end

post '/game/:id/delete' do
  g = GoGame.load(params[:id])
  return 404 unless g
  g.delete
  200
end

post '/game/:id/:color/move' do
  return 400 if missing?(params, [:x, :y])

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
