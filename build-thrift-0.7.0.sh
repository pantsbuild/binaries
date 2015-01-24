#!/bin/sh

# NB: The configure --wthout-* flags just disable building any runtime libs
# for the generated code.  We only want the codegen side of things.

curl -O http://archive.apache.org/dist/thrift/0.7.0/thrift-0.7.0.tar.gz && \
rm -rf thrift-0.7.0 && \
tar -xzf thrift-0.7.0.tar.gz && \
cd thrift-0.7.0 && \
sh ./configure \
  --disable-shared \
  --without-cpp \
  --without-c_glib \
  --without-csharp \
  --without-java \
  --without-erlang \
  --without-python \
  --without-perl \
  --without-php \
  --without-php_extension \
  --without-ruby \
  --without-haskell \
  --without-go && \
make LDFLAGS=-all-static
