#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.bash"

set_strict_mode

readonly CMAKE_VERSION_FOR_CLANG='3.9.5'

function build_cmake_for_clang_bootstrap {
  local -r cmake_linux_archive_abs="$(./build-cmake.sh linux "$CMAKE_VERSION_FOR_CLANG")"

  local -r workdir='cmake-for-linux-packages'

  with_pushd "$(mkdirp_absolute_path "$workdir")" \
             extract_for "$cmake_linux_archive_abs" 'bin/cmake'
}

function package_clang {
  local -r clang_version="$1"
  local -r cmake_linux_bin="$(build_cmake_for_clang_bootstrap)"

  CMAKE_EXE="$cmake_linux_bin" ./build-clang.sh linux "$clang_version"
}

package_clang "$1"
