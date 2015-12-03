#!/bin/sh

curl -O https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.bz2 && \
rm -rf protobuf-2.5.0 && \
tar -xjf protobuf-2.5.0.tar.bz2 && \
cd protobuf-2.5.0 && \
./configure --disable-shared && \
make LDFLAGS=-all-static

