#!/bin/bash

USE_RUBY_VERSION=$1
export PATH=$HOME/.rbenv/bin:$PATH

eval "`rbenv init -`"
cd /vagrant || exit 1
rbenv global $USE_VERSION

bundle install || exit 1
rbenv rehash

bundle exec rake jetty:stop 2>/dev/null
bundle exec rake jetty:clean || bundle exec rake jetty:unzip
if [ $? -ne 0 ]; then
    >&2 echo "Could not clean or unzip Jetty"
    exit 1
fi
bundle exec rake jetty:config
if [ $? -ne 0 ]; then
    >&2 echo "Could not configure Jetty"
    exit 1
fi
bundle exec rake jetty:start || exit 1

bundle exec rake engine_cart:clean && bundle exec rake engine_cart:generate
if [ $? -ne 0 ]; then
    >&2 echo "Could not generate wrapper application"
    exit 1
fi
