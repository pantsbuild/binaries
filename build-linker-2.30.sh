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

LINKER_SUPPORTDIR='build-support/bin/linker'
LINKER_PANTS_ARCHIVE_NAME='linker.tar.gz'
LINKER_BUILD_TMP_DIR='linker-tmp'

# default to -j2
MAKE_JOBS="${MAKE_JOBS:-2}"

## Linux (binutils, from source release)
BINUTILS_VERSION='2.30'
BINUTILS_TMP_ARCHIVE_CREATION_DIR='binutils-tmp'

mkdir -p "$LINKER_BUILD_TMP_DIR"
pushd "$LINKER_BUILD_TMP_DIR"

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
tar cvzf "$LINKER_PANTS_ARCHIVE_NAME" bin/ld
local linker_tools_linux_packaged_abs="$(pwd)/${LINKER_PANTS_ARCHIVE_NAME}"

popd

popd

mkdir -p "${LINKER_SUPPORTDIR}/linux/x86_64/${LINKER_VERSION}"
cp "$linker_tools_linux_packaged_abs" "${LINKER_SUPPORTDIR}/linux/x86_64/${LINKER_VERSION}/${LINKER_PANTS_ARCHIVE_NAME}"
