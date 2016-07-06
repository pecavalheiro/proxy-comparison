## Nginx Router Comparison

##### Runs a simple application in four different scenarios: Direct access (no container, no router router), app inside a container, simple nginx router (proxy) and dynamic-upstream proxy (nginx + lua).
After starting de desired application, run your benchmark against localhost:4000.

### Running the applications:

#### Direct access:

```bash
cd server
bundle install
ruby server.rb -e production -p 4000 puma
```

#### App in container:

```bash
cd server
docker build -t app .
docker run -p 4000:4000 -d app
```

#### App in container + Nginx Proxy:

```bash
docker network create routing
cd server
docker build -t app .
docker run -d --net=routing --name application app
cd ../nginx-default
docker build -t nginx-default .
docker run -p 4000:4000 -d --net=routing nginx-default
```
#### Dynamic router with 2 app containers (blue and green):

```bash
docker network create routing
docker run -p 6379:6379 --name redis --net=routing -d redis
cd server-blue
docker build -t app-blue .
docker run -d --net=routing --name app-blue app-blue
cd ../server-green
docker build -t app-green .
docker run -d --net=routing --name app-green app-green
cd ../nginx-lua
docker build -t nginx-lua .
docker run -p 4000:4000 -d --net=routing nginx-lua
```

#### EXTRA - router switch example (depends on nginx-lua above):

- Run a simple loop to watch the response changing. In a separate terminal: `while true; do curl localhost:4000; done;`
- Run the sample deploy script `cd deploy && ruby deploy.rb`
