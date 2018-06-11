#!/bin/bash

# TODO: this script was generatable from 'build-glibc.sh' with 3 text replacements. consider a
# utils.v2.bash in which we accumulate our learnings to abbreviate the process of building at least
# configure-based source releases, if not more.

source "$(git rev-parse --show-toplevel)/utils.v1.bash"

set_strict_mode

function fetch_extract_bison_source_release {
  local -r extracted_dirname="bison-${BISON_VERSION}"
  local -r archive_filename="${extracted_dirname}.tar.xz"
  local -r release_url="https://ftpmirror.gnu.org/bison/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  extract_for "$downloaded_archive" "$extracted_dirname"
}

function build_bison_with_configure {
  local -a configure_cmd_line=("$@")

  "${configure_cmd_line[@]}"

  make "-j${MAKE_JOBS}"

  make install
}

function build_linux {
  local -r source_extracted_abs="$(fetch_extract_bison_source_release)"

  local -r build_dir_abs="$(mkdirp_absolute_path 'bison-build')"
  local -r install_dir_abs="$(mkdirp_absolute_path 'bison-install')"

  with_pushd >&2 "$build_dir_abs" \
                 build_bison_with_configure \
                 "${source_extracted_abs}/configure" \
                 --prefix="$install_dir_abs"

  if [[ "${RETURN_ARCHIVE:-yes}" == 'yes' ]]; then
    with_pushd "$install_dir_abs" \
               create_gz_package 'bison'
  else
    with_pushd >&2 "$install_dir_abs" \
                   create_gz_package 'bison'
    echo "$install_dir_abs"
  fi
}

## Interpret arguments and execute build.

readonly TARGET_PLATFORM="$1" BISON_VERSION="$2"

MAKE_JOBS="${MAKE_JOBS:-2}"

# NB: $RETURN_ARCHIVE (default 'yes') == 'yes' prints the gzipped archive path to stdout as usual --
# otherwise, it prints the installation directory path to stdout (e.g. for use in another build
# script).

case "$TARGET_PLATFORM" in
  linux)
    with_pushd "$(mkdirp_absolute_path "bison-${BISON_VERSION}-linux")" \
               build_linux
    ;;
  *)
    die "bison does not support building for '${TARGET_PLATFORM}'"
    ;;
esac
