#!/bin/bash

source ./utils.bash

set_strict_mode

function fetch_extract_gcc_source_release {
  local -r extracted_dirname="gcc-${GCC_VERSION}"
  local -r archive_filename="${extracted_dirname}.tar.gz"
  local -r release_url="https://ftpmirror.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  extract_for "$downloaded_archive" "$extracted_dirname"
}

function build_gcc_with_configure {
  local -a configure_cmd_line=("$@")

  "${configure_cmd_line[@]}"

  make "-j${MAKE_JOBS}"

  make install
}

function build_gcc_out_of_tree {
  local -a configure_args=("$@")

  local -r source_extracted_abs="$(fetch_extract_gcc_source_release)"

  with_pushd >&2 "$source_extracted_abs" \
                 ./contrib/download_prerequisites

  local -r build_dir_abs="$(mkdirp_absolute_path 'gcc-build')"
  local -r install_dir_abs="$(mkdirp_absolute_path 'gcc-install')"

  with_pushd >&2 "$build_dir_abs" \
             build_gcc_with_configure  \
             "${source_extracted_abs}/configure" \
             --prefix="$install_dir_abs" \
             "${configure_args[@]}"

  with_pushd "$install_dir_abs" \
             create_gz_package 'gcc'
}

function build_osx {
  build_gcc_out_of_tree \
    --host='x86_64-apple-darwin' \
    --target='x86_64-apple-darwin' \
    AR="$(which ar)" \
    "${CONFIGURE_BASE_ARGS[@]}"
}

function build_linux {
  build_gcc_out_of_tree \
    "${CONFIGURE_BASE_ARGS[@]}"
}

## Interpret arguments and execute build.

readonly TARGET_PLATFORM="$1" GCC_VERSION="$2"

readonly MAKE_JOBS="${MAKE_JOBS:-2}"

readonly SUPPORTED_LANGS='c,c++,objc,obj-c++,fortran'

readonly -a CONFIGURE_BASE_ARGS=(
  --disable-multilib
  --enable-languages="${SUPPORTED_LANGS}"
  --enable-checking='release'
  --with-pkgversion="Pants-packaged GCC (${GCC_VERSION})"
  --with-bugurl='https://github.com/pantsbuild/pants/issues'
)

case "$TARGET_PLATFORM" in
  osx)
    with_pushd "$(mkdirp_absolute_path "gcc-${GCC_VERSION}-osx")" \
               build_osx
    ;;
  linux)
    with_pushd "$(mkdirp_absolute_path "gcc-${GCC_VERSION}-linux")" \
               build_linux
    ;;
  *)
    die "gcc does not support building for '${TARGET_PLATFORM}'"
    ;;
esac
