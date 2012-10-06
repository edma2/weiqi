require 'sinatra'
require './models'

get '/' do
  'hello world!'
end

get '/game' do
  ids = GoGame.all_ids
  ids.join("\n")
end

post '/game' do
  g = GoGame.new
  g.save
  200
end
