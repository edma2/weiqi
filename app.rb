require 'sinatra'
require './models'

get '/' do
  'hello world!'
end

get '/game' do
  ids = GoGame.all_ids
  JSON.generate(ids)
end

post '/game' do
  g = GoGame.new
  g.save
  200
end
