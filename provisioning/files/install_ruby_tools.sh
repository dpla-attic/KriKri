#!/bin/bash

USE_VERSION=$1

cd $HOME

if [ ! -d $HOME/.rbenv ]; then
    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv && \
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
        echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
        git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"

if [ -d $HOME/.rbenv/versions/$USE_VERSION ]; then
    export RBENV_VERSION=$USE_VERSION
else
    rbenv install $USE_VERSION
    if [ $? -ne 0 ]; then
        exit 1
    fi
    export RBENV_VERSION=$USE_VERSION
fi

bundler=`gem list bundler | grep bundler`
if [ -z "$bundler"]; then
    gem install bundler
else
    gem update bundler
fi
rbenv rehash

