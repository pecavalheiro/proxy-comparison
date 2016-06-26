require 'sinatra'
require 'colorize'

get '/' do
  "Hello World!".green
end
