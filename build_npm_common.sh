#!/bin/sh

install_node () {
  echo "Installing node"
  sudo apt-get update
  sudo apt-get install git-core curl build-essential openssl libssl-dev
  git clone https://github.com/joyent/node.git
  cd node
  ./configure
  make
  sudo make install
  node -v
}

install_npm () {
  echo "Installing NPM"
  curl http://npmjs.org/install.sh | sudo sh
  npm -v
}

if `node -v > /dev/null`; then
  echo "Node is installed"
  if `npm -v > /dev/null`; then
    echo "Npm is installed"
  else
    install_npm
  fi
else
  install_node
  install_npm
fi
