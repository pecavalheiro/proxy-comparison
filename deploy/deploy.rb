#!/usr/bin/env ruby

require 'rest-client'
require 'colorize'
require 'redis'
require 'slop'
require 'wannabe_bool'

redis = Redis.new(host: 'redis')

@opts = Slop.parse do |o|
  o.bool '-b', '--build', 'build'
end

available_upstreams = %w(green blue)
docker_network = 'deployment'

current_upstream = redis.get('current_upstream') || 'green'

new_upstream = current_upstream
new_upstream = available_upstreams.sample while new_upstream == current_upstream

puts "\n#####################
Current app is: #{current_upstream.to_s.send(current_upstream)}
New app is: #{new_upstream.to_s.send(new_upstream)}
#####################\n\n"

network_exists = `docker network ls | grep #{docker_network} | wc -l`.to_b
unless network_exists
  puts 'Creating docker network'.black.on_yellow; puts
  `docker network create deployment`
end

container_is_running = `docker ps -a -q --filter="name=app-#{new_upstream}" | wc -l`.to_b
if container_is_running
  print 'Stopping running container'.black.on_yellow; puts
  system("docker stop $(docker ps -a -q --filter='name=app-#{new_upstream}')")
end

if @opts[:build]
  print 'Rebuilding container, please wait a few moments'.black.on_yellow
  system("docker build -t app-#{new_upstream} ../server-#{new_upstream}") || raise('Error building containers')
end

puts; puts 'Removing old container'.black.on_yellow
system("docker rm app-#{new_upstream}")

puts; puts 'Starting updated application'.black.on_yellow
system "docker run --name=app-#{new_upstream} --net=#{docker_network} -d app-#{new_upstream} " || raise('Error starting container cloud')
sleep 10

puts; puts 'Container deployed!'.black.on_green

puts; puts 'Changing upstream'.black.on_light_blue
redis.set('current_upstream', new_upstream)
puts; puts 'Done!'.light_green.on_blue
