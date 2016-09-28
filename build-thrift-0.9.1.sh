#!/usr/bin/env bash

root=$(pwd -P)
INSTALL_PREFIX=install_root

# The 0.9.1 tarball has hardlinks that fail to extract properly on the /vagrant_data shared
# folder, using /tmp solves this.
workdir=$(mktemp -d -t build-thrift-0.9.1.XXXXXX)
cd ${workdir}

# Upgraded to 2.6.0 to pick up OSX linker fix: https://sourceforge.net/p/flex/bugs/182/
curl -L -O http://sourceforge.mirrorservice.org/f/fl/flex/flex-2.6.0.tar.gz && \
rm -rf flex-2.6.0 && \
tar -xzf flex-2.6.0.tar.gz && (
  cd flex-2.6.0 && \
  ./autogen.sh
  sh ./configure --prefix="$(pwd -P)/$INSTALL_PREFIX" && \
  make install
)

# NB: The configure --wthout-* flags just disable building any runtime libs
# for the generated code.  We only want the codegen side of things.
curl -L -O https://archive.apache.org/dist/thrift/0.9.1/thrift-0.9.1.tar.gz && \
rm -rf thrift-0.9.1 && \
tar -xzf thrift-0.9.1.tar.gz && \
LDFLAGS="-all-static -L$(pwd -P)/flex-2.6.0/$INSTALL_PREFIX/lib" && \
cd thrift-0.9.1 && \
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
make LDFLAGS="$LDFLAGS" && \
mv compiler/cpp/thrift ${root}/thrift-0.9.1.binary

