FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y && \
      apt-get install -y libreadline-dev \
      libncurses5-dev \
      libpcre3-dev \
      libssl-dev \
      perl \
      make \
      build-essential \
      curl \
      unzip

COPY openresty-1.9.15.1 openresty-1.9.15.1
COPY luarocks-2.3.0 luarocks-2.3.0

RUN cd openresty-1.9.15.1/ && \
      ./configure && \
      make && \
      make install 

RUN cd luarocks-2.3.0 && \
      ./configure --prefix=/usr/local/openresty/luajit \
      --with-lua=/usr/local/openresty/luajit \
      --lua-suffix=jit-2.1.0-beta2 \
      --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 && \
      make && \
      make install

RUN mkdir /logs

RUN cd /usr/local/openresty/luajit/bin && \
      ln -s luajit-2.1.0-beta2 lua

RUN PATH="/usr/local/openresty/luajit/bin:$PATH" \
      /usr/local/openresty/luajit/bin/luarocks install redis-lua

COPY nginx.conf /conf/nginx.conf

EXPOSE 4000

CMD /usr/local/openresty/nginx/sbin/nginx -p `pwd`/ -c conf/nginx.conf
