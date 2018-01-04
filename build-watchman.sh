#!/bin/bash

set -eo pipefail
set -x

DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
DIRPATH=$(pwd -P)
BUILD_DIR="watchman_build.${DATE}"

PCRE_VERSION="8.41"
PCRE_SHASUM="dddf0995aefe04cc6267c1448ffef0e7b0560ec0"
PCRE_DIR="pcre-${PCRE_VERSION}"
PCRE_TARBALL="${PCRE_DIR}.tar.gz"
PCRE_URL="http://downloads.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/${PCRE_TARBALL}"
PCRE_INSTALL_DIR="${DIRPATH}/${BUILD_DIR}/pcre_install"

OPENSSL_VERSION="1.0.2n"
OPENSSL_SHASUM="0ca2957869206de193603eca6d89f532f61680b1"
OPENSSL_DIR="openssl-${OPENSSL_VERSION}"
OPENSSL_TARBALL="${OPENSSL_DIR}.tar.gz"
OPENSSL_URL="https://www.openssl.org/source/${OPENSSL_TARBALL}"
OPENSSL_INSTALL_DIR="${DIRPATH}/${BUILD_DIR}/openssl_install"

case $(uname -s) in
  *Linux*) PLATFORM="linux";
           ARCH=`uname -p`;
           SHASUM="sha1sum";
           OPENSSL_ARCH="linux-x86_64";
           CFLAGS="-fPIC -fwrapv -O2";
           CXXFLAGS="${CFLAGS} -I${OPENSSL_INSTALL_DIR}/include";
           LDFLAGS="-L${OPENSSL_INSTALL_DIR}/lib";
           ;;
  *Darwin*) PLATFORM="mac";
            ARCH=`sw_vers -productVersion | cut -f1,2 -d.`;
            SHASUM="shasum";
            OPENSSL_ARCH="darwin64-x86_64-cc";
            CFLAGS="-fwrapv -Os";
            CXXFLAGS="${CFLAGS}";
            LDFLAGS="";
            ;;
  *) echo "unsupported platform!"; exit 1;;
esac

# WATCHMAN_VERSION="4.9.0"
WATCHMAN_VERSION="4.9.0-pants1"
WATCHMAN_DEST_DIR="${DIRPATH}/build-support/bin/watchman/${PLATFORM}/${ARCH}/${WATCHMAN_VERSION}"

echo "*****************************"
echo "building watchman ${WATCHMAN_VERSION}"
echo "*****************************"
echo

mkdir -p $BUILD_DIR
pushd $BUILD_DIR
  # PCRE build.
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

  # OpenSSL build (Linux only).
  if [ "${PLATFORM}" == "linux" ]; then
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
  fi

  # Watchman build.
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # TODO: Restore this, the watchman version and the `git checkout` line below once
  # https://github.com/facebook/watchman/pull/559 lands and is tagged/released.
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # git clone https://github.com/facebook/watchman.git watchman
  git clone https://github.com/kwlzn/watchman.git watchman
  pushd watchman
    # git checkout v${WATCHMAN_VERSION}
    git checkout kwlzn/spawn_strategy
    ./autogen.sh
    CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" ./configure --with-pcre=../pcre_install/bin/pcre-config --disable-statedir --without-python
    make watchman
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
