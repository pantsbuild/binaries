#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.bash"

set_strict_mode

function fetch_extract_glibc_source_release {
  local -r extracted_dirname="glibc-${GLIBC_VERSION}"
  local -r archive_filename="${extracted_dirname}.tar.xz"
  local -r release_url="https://ftpmirror.gnu.org/libc/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  extract_for "$downloaded_archive" "$extracted_dirname"
}

# TODO: consider adding this method to a utils.v2.bash.
function with_path {
  local -r path_contents="$1"
  local -a cmd=("${@:2}")
  PATH="$path_contents" "${cmd[@]}"
}

function build_glibc_with_configure {
  local -a configure_cmd_line=("$@")

  # Put bison's bin directory before the rest of the PATH to use our version of bison.
  local -r bison_bin_dir="${BISON_INSTALL_DIR}/bin"
  local -r our_bison_first_path="${bison_bin_dir}:${PATH}"

  with_path "$our_bison_first_path" \
            "${configure_cmd_line[@]}"

  with_path "$our_bison_first_path" \
            make "-j${MAKE_JOBS}"

  with_path "$our_bison_first_path" \
            make install
}

function build_linux {
  local -r source_extracted_abs="$(fetch_extract_glibc_source_release)"

  local -r build_dir_abs="$(mkdirp_absolute_path 'glibc-build')"
  local -r install_dir_abs="$(mkdirp_absolute_path 'glibc-install')"

  with_pushd >&2 "$build_dir_abs" \
                 build_glibc_with_configure \
                 "${source_extracted_abs}/configure" \
                 --prefix="$install_dir_abs"

  with_pushd "$install_dir_abs" \
             create_gz_package 'glibc'
}

## Interpret arguments and execute build.

readonly TARGET_PLATFORM="$1" GLIBC_VERSION="$2" BISON_INSTALL_DIR="$3"

MAKE_JOBS="${MAKE_JOBS:-2}"

case "$TARGET_PLATFORM" in
  linux)
    with_pushd "$(mkdirp_absolute_path "glibc-${GLIBC_VERSION}-linux")" \
               build_linux
    ;;
  *)
    die "glibc does not support building for '${TARGET_PLATFORM}'"
    ;;
esac
