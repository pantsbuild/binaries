#!/bin/sh

# NOTE: Ensure you have autoconf, automake and libtool installed via
        homebrew/apt-get/whatever.
 
curl -L -O https://github.com/google/protobuf/archive/v3.1.0.tar.gz && \
rm -rf protobuf-3.1.0 && \
tar -xjf v3.1.0.tar.gz && \
cd protobuf-3.1.0 && \
./autogen.sh && \
./configure && \
make
