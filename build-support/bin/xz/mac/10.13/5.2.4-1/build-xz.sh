#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.bash"

set_strict_mode

XZ_WRAPPER_SCRIPT="$(get_existing_absolute_path ./xz.py)"

function wrap_xz_lib_path_then_package {
  mv bin/xz{,-real}

  cp "$XZ_WRAPPER_SCRIPT" bin/xz

  chmod +x bin/xz

  create_gz_package 'xz'
}

function package_xz {
  local -r installed_dir_abs="$1"

  with_pushd "$installed_dir_abs" \
             wrap_xz_lib_path_then_package
}

function fetch_extract_xz_source_release {
  local -r archive_dirname="xz-${XZ_VERSION}"
  local -r archive_filename="${archive_dirname}.tar.gz"
  local -r release_url="https://tukaani.org/xz/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  extract_for "$downloaded_archive" "$archive_dirname"
}

function build_xz {
  local -r install_dir_abs="$1"

  # --disable-rpath is necessary to make the xz package work "out of the box" -- otherwise at
  # runtime it searches for a path in the filesystem of the VM that created it!
  ./configure \
    --disable-rpath \
    --prefix="$install_dir_abs"

  make "-j${MAKE_JOBS}"

  make install
}

function fetch_build_xz {
  local -r install_dir_abs="$(mkdirp_absolute_path 'xz-install')"

  local -r xz_src_extracted_abs="$(fetch_extract_xz_source_release)"

  with_pushd >&2 "$xz_src_extracted_abs" \
                 build_xz "$install_dir_abs"

  package_xz "$install_dir_abs"
}

readonly TARGET_PLATFORM="$1" XZ_VERSION="$2"

readonly MAKE_JOBS="${MAKE_JOBS:-2}"

case "$TARGET_PLATFORM" in
  osx)
    with_pushd "$(mkdirp_absolute_path "xz-${XZ_VERSION}-osx")" \
               fetch_build_xz
    ;;
  linux)
    with_pushd "$(mkdirp_absolute_path "xz-${XZ_VERSION}-linux")" \
               fetch_build_xz
    ;;
  *)
    die "xz does not support building for '${TARGET_PLATFORM}'"
    ;;
esac
