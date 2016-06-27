require 'sinatra'
require 'colorize'

get '/' do
  "Hello World!\n".blue
end
