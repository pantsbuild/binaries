#!/bin/sh

curl -L -O https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.bz2 && \
rm -rf protobuf-2.6.1 && \
tar -xjf protobuf-2.6.1.tar.bz2 && \
cd protobuf-2.6.1 && \
./configure --disable-shared && \
make LDFLAGS=-all-static
