#!/bin/sh

# We inject '#include <iostream>` in src/google/protobuf/message.cc
# The fix has landed, but it doesn't appear that they are maintaining a 2.4.1 branch.

# https://groups.google.com/forum/#!topic/protobuf/Sviq6XGjvDw

curl -L -O https://github.com/google/protobuf/releases/download/v2.4.1/protobuf-2.4.1.tar.bz2 && \
rm -rf protobuf-2.4.1 && \
tar -xjf protobuf-2.4.1.tar.bz2 && \
cd protobuf-2.4.1 && \
sed -i 's/#include <stack>/#include <stack>\n#include <iostream>/' src/google/protobuf/message.cc && \
./configure --disable-shared && \
make LDFLAGS=-all-static

