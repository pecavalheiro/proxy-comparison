require 'pp'
require 'rest-client'
require 'colorize'
require 'progress_bar'
require 'redis'
require 'slop'
require 'wannabe_bool'

redis = Redis.new(:host => "redis")

@opts = Slop.parse do |o|
  o.bool '-b', '--build', 'build'
end

available_upstreams = ['green', 'blue']
docker_network = 'deployment'

current_upstream = redis.get('current_upstream') || 'green'

new_upstream = current_upstream
new_upstream = available_upstreams.sample while new_upstream == current_upstream

puts; puts '#####################'
print ' Current app is: '
puts current_upstream.to_s.yellow
print ' New app is: '
puts new_upstream.to_s.red
puts '#####################'

network_exists = `docker network ls | grep #{docker_network} | wc -l`.to_b
unless network_exists
  puts; puts ' Creating docker network'.black.on_yellow
  `docker network create deployment`
end

container_is_running = `docker ps -a -q --filter="name=app-#{new_upstream}" | wc -l`.to_b
if container_is_running
  puts; puts ' Stopping running container'.black.on_yellow
  system("docker stop $(docker ps -a -q --filter='name=app-#{new_upstream}')")
end

if @opts[:build]
  puts; puts ' Rebuilding container, please wait a few moments'.black.on_yellow
  system("docker build -t app-#{new_upstream} ../server-#{new_upstream}") || raise('Error building containers')
end

puts; puts " Starting updated container on container #{new_upstream}".black.on_yellow
system("docker rm app-#{new_upstream}; docker run --name=app-#{new_upstream} --net=#{docker_network} -d app-#{new_upstream} ") || raise('Error starting container cloud')
sleep 10

puts; puts 'Container deployed!'.on_green

puts; puts 'Changing upstream'.light_yellow.on_green
redis.set('current_upstream', new_upstream)
puts; puts 'Done!'.light_green.on_blue
