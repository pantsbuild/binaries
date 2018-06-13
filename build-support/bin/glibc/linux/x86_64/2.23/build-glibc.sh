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

  "${configure_cmd_line[@]}" \
    --disable-intl \
    --disable-werror

  # Otherwise this tries to make hard links, which we can't do in our centos6 image.
  find . -name 'Make*' \
       | xargs sed -rie 's#ln -f #ln -sf #g'

  make "-j${MAKE_JOBS}"

  make install
}

function build_linux {
  local -r source_extracted_abs="$(fetch_extract_glibc_source_release)"

  local -r build_dir_abs="$(mkdirp_absolute_path 'glibc-build')"
  local -r install_dir_abs="$(mkdirp_absolute_path 'glibc-install')"

  # --disable-intl is necessary because it requires a bison version we don't have. We can build it
  # from source, but there's no reason to do that for this package.
  # --disable-werror is necessary, because -Werror defaults to on, but it
  # doesn't build by default in our centos6 image for some reason
  # (e.g. failing because of -Werror=dangling-else).
  with_pushd >&2 "$build_dir_abs" \
                 build_glibc_with_configure \
                 "${source_extracted_abs}/configure" \
                 --prefix="$install_dir_abs"

  with_pushd "$install_dir_abs" \
             create_gz_package 'glibc'
}

## Interpret arguments and execute build.

readonly TARGET_PLATFORM="$1" GLIBC_VERSION="$2"

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
