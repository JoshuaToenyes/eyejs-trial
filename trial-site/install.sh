#! /usr/bin/env bash

LIB_DIR=lib

# Install all npm packages and dependencies.
npm install

# Install and update Bourbon, Neat, and SASS.
cd $LIB_DIR
sudo gem install neat
sudo gem install sass
sudo gem install bourbon
sudo gem install bitters
bourbon install
neat install
bitters install

exit 0
