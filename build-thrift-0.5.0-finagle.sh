#!/bin/sh

# NB: The configure --wthout-* flags just disable building any runtime libs
# for the generated code.  We only want the codegen side of things.

curl -LO https://github.com/pantsbuild/thrift-0.5.0-finagle/archive/pantsbuild-binaries-0.5.0-finagle.tar.gz && \
rm -rf thrift-0.5.0-finagle-pantsbuild-binaries-0.5.0-finagle && \
tar -xzf pantsbuild-binaries-0.5.0-finagle.tar.gz && \
cd thrift-0.5.0-finagle-pantsbuild-binaries-0.5.0-finagle && \
./configure \
  --disable-shared \
  --without-cpp \
  --without-csharp \
  --without-java \
  --without-erlang \
  --without-python \
  --without-perl \
  --without-php \
  --without-php_extension \
  --without-ruby \
  --without-haskell && \
make LDFLAGS=-all-static
