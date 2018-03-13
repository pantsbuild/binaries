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

# default to -j2
MAKE_JOBS="${MAKE_JOBS:-2}"

## Linux (binutils, from source release)
BINUTILS_VERSION='2.30'
BINUTILS_TMP_ARCHIVE_CREATION_DIR='binutils-tmp'

mkdir -p "$BINUTILS_BUILD_TMP_DIR"
pushd "$BINUTILS_BUILD_TMP_DIR"

curl -L -O "https://ftpmirror.gnu.org/binutils/binutils-${BINUTILS_VERSION}.tar.xz"
tar xf "binutils-${BINUTILS_VERSION}.tar.xz"
pushd "binutils-${BINUTILS_VERSION}"

./configure
make -j"$MAKE_JOBS"

popd

rm -rf "$BINUTILS_TMP_ARCHIVE_CREATION_DIR"
mkdir "$BINUTILS_TMP_ARCHIVE_CREATION_DIR"
pushd "$BINUTILS_TMP_ARCHIVE_CREATION_DIR"

mkdir bin
cp "../binutils-${BINUTILS_VERSION}/ld/ld-new" bin/ld
tar cvzf "$BINUTILS_PANTS_ARCHIVE_NAME" bin/ld
binutils_linux_packaged_abs="$(pwd)/${BINUTILS_PANTS_ARCHIVE_NAME}"

popd

popd

mkdir -p "${BINUTILS_SUPPORTDIR}/linux/x86_64/${BINUTILS_VERSION}"
cp "$binutils_linux_packaged_abs" \
   "${BINUTILS_SUPPORTDIR}/linux/x86_64/${BINUTILS_VERSION}/${BINUTILS_PANTS_ARCHIVE_NAME}"
