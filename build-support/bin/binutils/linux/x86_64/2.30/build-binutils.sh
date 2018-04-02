#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.bash"

set_strict_mode

function fetch_extract_binutils_source_release {
  local -r extracted_dirname="binutils-${BINUTILS_VERSION}"
  local -r archive_filename="${extracted_dirname}.tar.xz"
  local -r release_url="https://ftpmirror.gnu.org/binutils/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  extract_for "$downloaded_archive" "$extracted_dirname"
}

function build_binutils_with_configure {
  local -a configure_cmd_line=("$@")

  "${configure_cmd_line[@]}"

  make "-j${MAKE_JOBS}"

  make install
}

function build_linux {
  local -r source_extracted_abs="$(fetch_extract_binutils_source_release)"

  local -r build_dir_abs="$(mkdirp_absolute_path 'binutils-build')"
  local -r install_dir_abs="$(mkdirp_absolute_path 'binutils-install')"

  with_pushd >&2 "$build_dir_abs" \
             build_binutils_with_configure \
             "${source_extracted_abs}/configure" \
             --prefix="$install_dir_abs"

  with_pushd "$install_dir_abs" \
             create_gz_package 'binutils' bin
}

## Interpret arguments and execute build.

readonly TARGET_PLATFORM="$1" BINUTILS_VERSION="$2"

MAKE_JOBS="${MAKE_JOBS:-2}"

case "$TARGET_PLATFORM" in
  linux)
    with_pushd "$(mkdirp_absolute_path "binutils-${BINUTILS_VERSION}-linux")" \
               build_linux
    ;;
  *)
    die "binutils doesnot support building for '${TARGET_PLATFORM}'"
    ;;
esac
