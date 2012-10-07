require 'sinatra'
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

post '/game' do
  g = GoGame.new
  g.save
  200
end

post '/game/:id/add' do
  return 400 if missing?(params, [:x, :y, :color])

  x = params[:x].to_i
  y = params[:y].to_i
  color = params[:color].to_i

  if x <= 19 && y <= 19 && [0, 1].include?(color)
    g = GoGame.load(params[:id])
    return 404 unless g
    g.set(x, y, color)
    g.save
    200
  else
    400
  end
end

post '/game/:id/remove' do
  return 400 if missing?(params, [:x, :y])

  x = params[:x].to_i
  y = params[:y].to_i

  if x <= 19 && y <= 19
    g = GoGame.load(params[:id])
    return 404 unless g
    g.unset(x, y)
    g.save
    200
  else
    400
  end
end
