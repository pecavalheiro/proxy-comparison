## Nginx Proxy Benchmarking

##### Request time benchmarking for a simple application in three different scenarios: Direct access (no proxy), simple proxy and (TODO) a dynamic-upstream proxy .

### Running the benchmark:

#### Run the server (direct access):

``` cd server && ruby server.rb -e production -p 4000```

#### Run the benchmark:
``` ruby benchmark.rb```

The output will be something like

|      |   user   |  system  |   total  |     real    |
|------|----------|----------|----------|-------------|
| ruby | 5.890000 | 1.220000 | 7.110000 | (13.827685) |
| >avg | 0.000589 | 0.000122 | 0.000711 |  (0.001383) |

#### Run the proxy and server (as Docker containers):

```bash
docker network create -d bridge benchmarking
cd server
docker build -t sinatra .
docker run --name=sinatra -p 4000:4000 --net=benchmarking -d sinatra
cd ../nginx-default
docker build -t proxy .
docker run -d -p 4001:4000 --net=benchmarking proxy
cd ..
ruby benchmark.rb 4001
```

|      |   user   |  system  |   total  |     real    |
|------|----------|----------|----------|-------------|
| ruby | 5.910000 | 1.290000 | 7.200000 | (27.576583) |
| >avg | 0.000591 | 0.000129 | 0.000720 |  (0.002758) |
