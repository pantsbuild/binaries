#!/bin/bash

set -eo pipefail
set -x

case $(uname -s) in
  *Linux*) PLATFORM="linux";
           ARCH=`uname -p`;
           SHASUM="sha1sum";
           OPENSSL_ARCH="linux-x86_64";
           CFLAGS="-fPIC -fwrapv -O2"
           ;;
  *Darwin*) PLATFORM="mac";
            ARCH=`sw_vers -productVersion | cut -f1,2 -d.`;
            SHASUM="shasum";
            OPENSSL_ARCH="darwin64-x86_64-cc";
            CFLAGS="-fwrapv -Os"
            ;;
  *) echo "unsupported platform!"; exit 1;;
esac

DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
DIRPATH=$(pwd -P)
BUILD_DIR="watchman_build.${DATE}"

WATCHMAN_DEST_DIR="${DIRPATH}/build-support/bin/watchman/${PLATFORM}/${ARCH}/${WATCHMAN_VERSION}"
WATCHMAN_VERSION="4.9.0"

PCRE_VERSION="8.41"
PCRE_SHASUM="dddf0995aefe04cc6267c1448ffef0e7b0560ec0"
PCRE_DIR="pcre-${PCRE_VERSION}"
PCRE_TARBALL="${PCRE_DIR}.tar.gz"
PCRE_URL="http://downloads.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/${PCRE_TARBALL}"
PCRE_INSTALL_DIR="${DIRPATH}/${BUILD_DIR}/pcre_install"

OPENSSL_VERSION="1.0.2l"
OPENSSL_SHASUM="b58d5d0e9cea20e571d903aafa853e2ccd914138"
OPENSSL_DIR="openssl-${OPENSSL_VERSION}"
OPENSSL_TARBALL="${OPENSSL_DIR}.tar.gz"
OPENSSL_URL="https://www.openssl.org/source/${OPENSSL_TARBALL}"
OPENSSL_INSTALL_DIR="${DIRPATH}/${BUILD_DIR}/openssl_install"

echo "*****************************"
echo "building watchman ${WATCHMAN_VERSION}"
echo "*****************************"
echo

mkdir -p $BUILD_DIR
pushd $BUILD_DIR
  # PCRE Build.
  curl -LO $PCRE_URL
  if [ $($SHASUM $PCRE_TARBALL | grep -c $PCRE_SHASUM) -ne "1" ]; then
    set +x
    echo "pcre checksum invalid! aborting build."
    exit 1
  fi
  tar zxf $PCRE_TARBALL
  pushd $PCRE_DIR
    CFLAGS="${CFLAGS}" ./configure --enable-static --disable-shared --prefix="${PCRE_INSTALL_DIR}"
    make
    make install
  popd

  # OpenSSL Build.
  curl -LO $OPENSSL_URL
  if [ $($SHASUM $OPENSSL_TARBALL | grep -c $OPENSSL_SHASUM) -ne "1" ]; then
    set +x
    echo "openssl checksum invalid! aborting build."
    exit 1
  fi
  tar zxf $OPENSSL_TARBALL
  pushd $OPENSSL_DIR
    CFLAGS="${CFLAGS}" ./Configure no-shared -fPIC --prefix="${OPENSSL_INSTALL_DIR}" "${OPENSSL_ARCH}"
    make depend
    make -j8
    make install
  popd

  # Watchman Build.
  git clone https://github.com/facebook/watchman.git watchman
  pushd watchman
    git checkout v${WATCHMAN_VERSION}
    ./autogen.sh
    CXXFLAGS="${CFLAGS} -I${OPENSSL_INSTALL_DIR}/include" LDFLAGS="-L${OPENSSL_INSTALL_DIR}/lib" ./configure --with-pcre=../pcre_install/bin/pcre-config --disable-statedir --without-python
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
