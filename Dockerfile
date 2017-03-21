FROM ruby:2.3.3


### DEPENDENCIES ###

# RUN apt-get update && apt-get install -y \
#   less \
#   postgresql-client-9.4


### PREPARE ###

# Don't install doc for ruby gems
RUN echo 'gem: --no-rdoc --no-ri' > /etc/gemrc

RUN mkdir /app
WORKDIR /app

# copy over Gemfile and install bundle
ADD Gemfile .
ADD Gemfile.lock .
ADD echo_common.gemspec .
ADD lib/echo_common/version.rb /app/lib/echo_common/version.rb

RUN bundle install --jobs 20 --retry 5

COPY . .