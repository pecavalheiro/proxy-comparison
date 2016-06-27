require 'sinatra'
require 'colorize'

get '/' do
  "Hello World!\n".green
end
