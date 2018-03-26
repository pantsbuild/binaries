#!/bin/bash

source ./utils.bash
source ./vars.bash

set_strict_mode

readonly -a BINUTILS_VERSIONS=(
  '2.30'
)

readonly -a CLANG_VERSIONS=(
  '5.0.1'
  '6.0.0'
)

readonly -a GCC_VERSIONS=(
  '7.3.0'
)

readonly CMAKE_VERSION_FOR_CLANG='3.9.5'

function build_cmake_for_clang_bootstrap {
  local -r cmake_linux_archive_abs="$(./build-cmake.sh linux "$CMAKE_VERSION_FOR_CLANG")"

  local -r workdir='cmake-for-linux-packages'

  with_pushd "$(mkdirp_absolute_path "$workdir")" \
             extract_for "$cmake_linux_archive_abs" 'bin/cmake'
}

function package_binutils {
  for binutils_version in "${BINUTILS_VERSIONS[@]}"; do
    binutils_linux_pkg="$(./build-binutils.sh linux "$binutils_version")"
    get_create_linux_supportdirs_stdout binutils "$binutils_version" \
      | deploy_package_to_dirs_from_stdin "$binutils_linux_pkg"
  done
}

function package_gcc {
  for gcc_version in "${GCC_VERSIONS[@]}"; do
    gcc_linux_pkg="$(./build-gcc.sh linux "$gcc_version")"
    get_create_linux_supportdirs_stdout gcc "$gcc_version" \
      | deploy_package_to_dirs_from_stdin "$gcc_linux_pkg"

    gcc_osx_pkg="$(./build-gcc.sh osx "$gcc_version")"
    get_create_osx_supportdirs_stdout gcc "$gcc_version" \
      | deploy_package_to_dirs_from_stdin "$gcc_osx_pkg"
  done
}

function package_clang {
  readonly cmake_linux_bin="$(build_cmake_for_clang_bootstrap)"

  for clang_version in "${CLANG_VERSIONS[@]}"; do
    clang_osx_pkg="$(./build-clang.sh osx "$clang_version")"
    get_create_osx_supportdirs_stdout clang "$clang_version" \
      | deploy_package_to_dirs_from_stdin "$clang_osx_pkg"

    clang_linux_pkg="$(CMAKE_EXE="$cmake_linux_bin" \
      ./build-clang.sh linux "$clang_version")"
    get_create_linux_supportdirs_stdout clang "$clang_version" \
      | deploy_package_to_dirs_from_stdin "$clang_linux_pkg"
  done
}

readonly TOOL_NAME="$1"

case "$TOOL_NAME" in
  binutils)
    package_binutils
    ;;
  clang)
    package_clang
    ;;
  gcc)
    package_gcc
    ;;
  *)
    die "Tool not recognized: '${TOOL_NAME}'"
    ;;
esac
