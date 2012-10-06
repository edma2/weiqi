require 'sinatra'
require './models'
require './init/redis'

get '/' do
  'hello world!'
end
