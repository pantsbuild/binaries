#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.bash"

set_strict_mode

function fetch_extract_make_source_release {
  local -r extracted_dirname="make-${MAKE_VERSION}"
  local -r archive_filename="${extracted_dirname}.tar.gz"
  local -r release_url="https://ftpmirror.gnu.org/gnu/make/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  extract_for "$downloaded_archive" "$extracted_dirname"
}

function build_make_with_configure {
  local -a configure_cmd_line=("$@")

  "${configure_cmd_line[@]}"

  make "-j${SUBPROC_MAKE_JOBS}"

  make install
}

function build_make_out_of_tree {
  local -r source_extracted_abs="$(fetch_extract_make_source_release)"
  local -r build_dir_abs="$(mkdirp_absolute_path 'make-build')"
  local -r install_dir_abs="$(mkdirp_absolute_path 'make-install')"

  with_pushd >&2 "$build_dir_abs" \
             build_make_with_configure  \
             "${source_extracted_abs}/configure" \
             --prefix="$install_dir_abs"

  with_pushd "$install_dir_abs" \
             create_gz_package 'make'
}

## Interpret arguments and execute build.

readonly MAKE_VERSION="$1"
# Default to 2 parallel jobs if unspecified.
readonly SUBPROC_MAKE_JOBS="${SUBPROC_MAKE_JOBS:-2}"

case "$(uname)" in
  Darwin)
    with_pushd "$(mkdirp_absolute_path "make-${MAKE_VERSION}-osx")" \
               build_make_out_of_tree
    ;;
  Linux)
    with_pushd "$(mkdirp_absolute_path "make-${MAKE_VERSION}-linux")" \
               build_make_out_of_tree
    ;;
  *)
    die "make does not support building for '$(uname)'"
    ;;
esac
