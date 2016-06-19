FROM ruby:2.3.1

RUN gem install sinatra

COPY server.rb /app/server.rb
COPY Gemfile /app/Gemfile

RUN cd /app && bundle install

EXPOSE 4567

CMD cd /app && ruby server.rb -o 0.0.0.0 -e production
