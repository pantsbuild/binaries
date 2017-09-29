#!/bin/sh

# NOTE: Ensure you have autoconf, automake and libtool installed via
#       homebrew/apt-get/whatever.

curl -L -O https://github.com/google/protobuf/archive/v3.4.1.tar.gz && \
rm -rf protobuf-3.4.1 && \
tar -xzf v3.4.1.tar.gz && \
cd protobuf-3.4.1 && \
./autogen.sh && \
./configure --disable-shared && \
make
