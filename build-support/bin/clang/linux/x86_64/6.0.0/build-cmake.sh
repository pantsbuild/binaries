#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.bash"

set_strict_mode

readonly CMAKE_VERSION_PATTERN='^([0-9]+\.[0-9]+)\.[0-9]+$'

function extract_minor_version {
  local -r version_string="$1"

  echo "$version_string" | sed -re "s#${CMAKE_VERSION_PATTERN}#\\1#g"
}

function fetch_extract_cmake_binary_release {
  local -r extracted_dirname="$1"

  local -r cmake_minor_version="$(extract_minor_version "$CMAKE_VERSION")"

  local -r archive_filename="${extracted_dirname}.tar.gz"
  local -r release_url="https://cmake.org/files/v${cmake_minor_version}/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  extract_for "$downloaded_archive"  "$extracted_dirname"
}

function package_cmake {
  local -r installed_dir_abs="$1"

  with_pushd "$installed_dir_abs" \
             create_gz_package 'cmake' bin share
}

function build_osx {
  local -r cmake_platform_description="cmake-${CMAKE_VERSION}-Darwin-x86_64"

  local -r extracted_dir="$(fetch_extract_cmake_binary_release "$cmake_platform_description")"

  package_cmake "${extracted_dir}/CMake.app/Contents"
}

function build_linux {
  local -r cmake_platform_description="cmake-${CMAKE_VERSION}-Linux-x86_64"

  local -r extracted_dir="$(fetch_extract_cmake_binary_release "$cmake_platform_description")"

  package_cmake "$extracted_dir"
}


## Interpret arguments and execute build.

readonly TARGET_PLATFORM="$1" CMAKE_VERSION="$2"

case "$TARGET_PLATFORM" in
  osx)
    with_pushd "$(mkdirp_absolute_path "cmake-${CMAKE_VERSION}-osx")" \
               build_osx
    ;;
  linux)
    with_pushd "$(mkdirp_absolute_path "cmake-${CMAKE_VERSION}-linux")" \
               build_linux
    ;;
  *)
    die "cmake does not support building for '${TARGET_PLATFORM}'"
    ;;
esac
