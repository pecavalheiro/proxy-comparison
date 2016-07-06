FROM ruby:2.3.1

RUN gem install sinatra

COPY Gemfile /app/Gemfile

RUN cd /app && bundle install

COPY server.rb /app/server.rb

EXPOSE 4000

CMD cd /app && ruby server.rb -o 0.0.0.0 -e production -p 4000 puma
