#!/usr/bin/env ruby
@network = 'deployment'

def network_exists?
  return true if `docker network ls | grep #{@network} | wc -l`.to_i > 0
end

unless network_exists?
  puts 'Creating docker network'
  `docker network create #{@network}`
end

puts 'Starting Redis container'
`docker rm redis`
`docker run -p 6379:6379 --name redis --net=#{@network} -d redis`

puts 'Building App containers'
system('docker build -t app-green server-green/')
system('docker build -t app-blue server-blue/')

puts 'Building Router container'
system('docker build -t router-lua nginx-lua/')

puts 'Running App containers'
`docker rm app-green`
system("docker run --name=app-green --net=#{@network} -d app-green")
`docker rm app-blue`
system("docker run --name=app-blue --net=#{@network} -d app-blue")

puts 'Running Router container'
`docker rm router-lua`
system("docker run -p 4000:4000 --net=#{@network} -d router-lua")
