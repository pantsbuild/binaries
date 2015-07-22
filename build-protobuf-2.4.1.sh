#!/bin/sh

curl -O https://protobuf.googlecode.com/files/protobuf-2.4.1.tar.bz2 && \
rm -rf protobuf-2.4.1 && \
tar -xjf protobuf-2.4.1.tar.bz2 && \
cd protobuf-2.4.1 && \
./configure --disable-shared && \
make LDFLAGS=-all-static

