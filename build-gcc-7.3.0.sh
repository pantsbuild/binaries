#!/bin/bash

set -euxo pipefail

MAKE_JOBS="${MAKE_JOBS:-2}"

GCC_VERSION='7.3.0'
GCC_TMP_DIR='gcc-tmp'
GCC_BUILD_DIR='gcc-build'
GCC_INSTALL_DIR='gcc-install'
GCC_PKG_TARBALL='gcc.tar.gz'
GCC_SUPPORTDIR='build-support/bin/gcc/'

GCC_SUPPORTED_LANGS='c,c++,objc,obj-c++,fortran'

function get_absolute_path {
  readlink -f "$1"
}

function configure_args {
  local -r pfx_dir_abs="$1"

  cat <<EOF
--prefix=${pfx_dir_abs}
--enable-languages=${GCC_SUPPORTED_LANGS}
--enable-checking=release
--with-pkgversion=Pants-packaged GCC (${GCC_VERSION})
--with-bugurl=https://github.com/pantsbuild/pants/issues
EOF

  if [[ "$(uname)" = 'Darwin' ]]; then
    cat <<EOF
--build=x86_64-apple-darwin$(uname -r)
--with-system-zlib
EOF
  fi
}

mkdir -p "$GCC_TMP_DIR"
pushd "$GCC_TMP_DIR"

# FIXME: verify contents of this file somehow. there's a .sig file at the same
# location, and one of the gpg keys mentioned on
# https://gcc.gnu.org/mirrors.html can be used to perform the verification.
curl -L -O "https://ftpmirror.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz"

tar zxf "gcc-${GCC_VERSION}.tar.gz"

pushd "gcc-${GCC_VERSION}"

./contrib/download_prerequisites

popd

mkdir -p "$GCC_BUILD_DIR"
mkdir -p "$GCC_INSTALL_DIR"

install_dir_abs="$(get_absolute_path "../${GCC_INSTALL_DIR}")"

pushd "$GCC_BUILD_DIR"

unset LD

configure_script_path="../gcc-${GCC_VERSION}/configure"

configure_args "$install_dir_abs" \
  | xargs "$configure_script_path" -t

make "-j${MAKE_JOBS}"

make install

popd

pushd "$GCC_INSTALL_DIR"

tar cvzf "$GCC_PKG_TARBALL" bin include lib lib64 libexec
gcc_packaged_abs="$(get_absolute_path "$GCC_PKG_TARBALL")"

popd

popd

gcc_outdir_abs="${GCC_SUPPORTDIR}/linux/x86_64/${GCC_VERSION}/"
mkdir -p "$gcc_outdir_abs"
cp "$gcc_packaged_abs" "$gcc_outdir_abs"
