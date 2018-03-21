#!/bin/bash

# NOTE: This script ONLY builds a Linux 64-bit binary! OSX uses the XCode
# command-line tools installed on the system to link executables.

if ! hash xz; then
  cat >&2 <<EOF
'xz' is required to run this script. You may have to install it using your
operating system's package manager.
EOF
  exit 1
fi

set -euxo pipefail

BINUTILS_SUPPORTDIR='build-support/bin/binutils'
BINUTILS_PANTS_ARCHIVE_NAME='binutils.tar.gz'
BINUTILS_BUILD_TMP_DIR='binutils-tmp'
BINUTILS_INSTALL_DIRNAME='binutils-install'

BINUTILS_SRC_DIRNAME="binutils-${BINUTILS_VERSION}"
BINUTILS_RELEASE_ARCHIVE_NAME="binutils-${BINUTILS_VERSION}.tar.xz"
BINUTILS_RELEASE_URL="https://ftpmirror.gnu.org/binutils/${BINUTILS_RELEASE_ARCHIVE_NAME}"

# default to -j2
MAKE_JOBS="${MAKE_JOBS:-2}"

## Linux (binutils, from source release)
BINUTILS_VERSION='2.30'
BINUTILS_TMP_ARCHIVE_CREATION_DIR='binutils-tmp'

mkdir -p "$BINUTILS_BUILD_TMP_DIR"
pushd "$BINUTILS_BUILD_TMP_DIR" # root -> $BINUTILS_BUILD_TMP_DIR

curl -L -v -O "$BINUTILS_RELEASE_URL"
tar xf "$BINUTILS_RELEASE_ARCHIVE_NAME"

mkdir -p "$BINUTILS_INSTALL_DIRNAME"
binutils_install_dir_abs="$(pwd)/${BINUTILS_INSTALL_DIRNAME}"

pushd "$BINUTILS_SRC_DIRNAME"   # $BINUTILS_BUILD_TMP_DIR -> $BINUTILS_SRC_DIRNAME

./configure \
  "--prefix=${binutils_install_dir_abs}"

make -j"$MAKE_JOBS"

make install

popd                            # $BINUTILS_BUILD_TMP_DIR <- $BINUTILS_SRC_DIRNAME

pushd "$BINUTILS_INSTALL_DIRNAME" # $BINUTILS_BUILD_TMP_DIR -> $BINUTILS_INSTALL_DIRNAME

tar cvzf "$BINUTILS_PANTS_ARCHIVE_NAME" *
binutils_linux_packaged_abs="$(pwd)/${BINUTILS_PANTS_ARCHIVE_NAME}"

popd                            # $BINUTILS_BUILD_TMP_DIR <- $BINUTILS_INSTALL_DIRNAME

popd                            # root <- $BINUTILS_BUILD_TMP_DIR

# We only provide binutils on Linux (there is no open source OSX linker right
# now), and we are choosing not to support 32-bit hosts unless there is a clear
# need, so we only need to fill up one directory here.
mkdir -p "${BINUTILS_SUPPORTDIR}/linux/x86_64/${BINUTILS_VERSION}"
cp "$binutils_linux_packaged_abs" \
   "${BINUTILS_SUPPORTDIR}/linux/x86_64/${BINUTILS_VERSION}/${BINUTILS_PANTS_ARCHIVE_NAME}"
