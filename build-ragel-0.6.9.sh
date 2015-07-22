#!/bin/sh

if `uname -s | grep -i darwin &> /dev/null`; then
  unset LDFLAGS
else
  LDFLAGS=-static
fi

curl -k -O https://www.colm.net/files/ragel/ragel-6.9.tar.gz && \
rm -rf ragel-6.9 && \
tar -xzf ragel-6.9.tar.gz && \
cd ragel-6.9 && \
./configure && \
make LDFLAGS=$LDFLAGS

