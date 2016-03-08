#!/bin/sh

set -eo pipefail

WATCHMAN_VERSION="4.5.0"
PCRE_VERSION="8.38"

echo "*****************************"
echo "building watchman ${WATCHMAN_VERSION}"
echo "*****************************"
echo
set -x

case $(uname -s) in
  *Linux*) PLATFORM="linux"
           ARCH=`uname -p`;;
  *Darwin*) PLATFORM="mac";
            ARCH=`sw_vers -productVersion | cut -f1,2 -d.`;;
  *) echo "invalid platform"; exit 1;;
esac

DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
DIRPATH=$(pwd -P)
WATCHMAN_DEST_DIR="${DIRPATH}/build-support/bin/watchman/${PLATFORM}/${ARCH}/${WATCHMAN_VERSION}"
BUILD_DIR="watchman_build.${DATE}"
mkdir -p $BUILD_DIR

PCRE_DIR="pcre-${PCRE_VERSION}"
PCRE_TARBALL="${PCRE_DIR}.tar.gz"
PCRE_URL="http://downloads.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/${PCRE_TARBALL}"
PCRE_INSTALL_DIR="${DIRPATH}/${BUILD_DIR}/pcre_install"

pushd $BUILD_DIR
  # PCRE Build.
  curl -LO $PCRE_URL
  tar zxf $PCRE_TARBALL
  pushd $PCRE_DIR
    ./configure --enable-static --disable-shared --prefix=$PCRE_INSTALL_DIR
    make
    make install
  popd

  # Watchman Build.
  git clone https://github.com/facebook/watchman.git watchman
  pushd watchman
    git checkout v${WATCHMAN_VERSION}
    ./autogen.sh
    ./configure --with-pcre=../pcre_install/bin/pcre-config --without-python
    make
    mkdir -p $WATCHMAN_DEST_DIR
    cp watchman $WATCHMAN_DEST_DIR/
  popd
popd

rm -rf $BUILD_DIR

set +x
echo
echo "*****************************"
echo "build completed successfully!"
echo "*****************************"
