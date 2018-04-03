#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.bash"

set_strict_mode

function package_clang {
  local -r installed_dir_abs="$1"

  with_pushd "$installed_dir_abs" \
             create_gz_package 'clang'
}

## Build for OSX from LLVM's binary release package.

function build_osx {

  local -r normal_release_dirname="clang+llvm-${LLVM_VERSION}-x86_64-apple-darwin"
  # The top-level directory in the release archive is not always the same across
  # releases. The `-final-` part may be to signify that this is the last release
  # of that major version.
  local -r final_release_dirname="clang+llvm-${LLVM_VERSION}-final-x86_64-apple-darwin"

  local -r archive_filename="${normal_release_dirname}.tar.xz"
  local -r release_url="https://releases.llvm.org/${LLVM_VERSION}/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  local -r extracted_dir="$(extract_for "$downloaded_archive" "$normal_release_dirname" "$final_release_dirname")"

  package_clang "$extracted_dir"
}


## Build for Linux from LLVM's multi-part source release packages.

function fetch_extract_llvm_source_release {
  local -r extracted_dirname="$1"

  local -r archive_filename="${extracted_dirname}.tar.xz"
  local -r release_url="https://releases.llvm.org/${LLVM_VERSION}/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  extract_for "$downloaded_archive" "$extracted_dirname"
}

function build_llvm_with_cmake {
  local -r cmake_exe="$1" install_dir="$2" cfe_dir="$3" llvm_dir="$4"

  # This didn't immediately compile right off the bat -- I'd recommend to anyone
  # watching that Homebrew formulas are good places to learn about how to provide
  # high-quality toolchains on OSX. I found https://llvm.org/docs/CMake.html
  # "helpful" for this line as well.
  "$cmake_exe" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$install_dir_abs" \
    -DLLVM_EXTERNAL_CLANG_SOURCE_DIR="$cfe_dir" \
    -DLLVM_EXTERNAL_PROJECTS='clang' \
    -DLLVM_TARGETS_TO_BUILD='X86' \
    -DBACKEND_PACKAGE_STRING="Pants-packaged LLVM for ${TARGET_PLATFORM}, version ${LLVM_VERSION}" \
    "$llvm_dir"

  # NB: There appear to be race conditions when running make with any
  # parallelism here in a Docker image.
  make "-j${MAKE_JOBS}"

  make install
}

function build_linux {
  local -r cmake_exe="$1"

  # Properties of the downloaded release tarball.
  local -r llvm_src_dirname="llvm-${LLVM_VERSION}.src"
  local -r cfe_src_dirname="cfe-${LLVM_VERSION}.src"

  # Set up an out-of-tree build and install
  local -r build_dir_abs="$(mkdirp_absolute_path 'clang-llvm-build')"
  local -r install_dir_abs="$(mkdirp_absolute_path 'clang-llvm-install')"

  # LLVM requires you to download the source for LLVM and the Clang frontend
  # separately. One alternative is checking out their SVN repo, but that takes
  # much longer.
  local -r llvm_src_extracted_abs="$(fetch_extract_llvm_source_release "$llvm_src_dirname")"
  local -r cfe_src_extracted_abs="$(fetch_extract_llvm_source_release "$cfe_src_dirname")"

  # Redirect to stderr because we "return" a path to our .tar.gz by stdout.
  with_pushd >&2 "$build_dir_abs" \
             build_llvm_with_cmake "$cmake_exe" "$install_dir_abs" "$cfe_src_extracted_abs" "$llvm_src_extracted_abs"

  package_clang "$install_dir_abs"
}

function validate_cmake {
  if [[ ! -f "$CMAKE_EXE" ]]; then
    die_here <<EOF
To build clang for Linux, the environment variable \$CMAKE_EXE=${CMAKE_EXE} must
be an absolute path to a 'cmake' binary that is executable on the current host.
EOF
  fi
  echo "$CMAKE_EXE"
}


## Interpret arguments and execute build.

readonly TARGET_PLATFORM="$1" LLVM_VERSION="$2"

readonly MAKE_JOBS="${MAKE_JOBS:-2}"

case "$TARGET_PLATFORM" in
  osx)
    with_pushd "$(mkdirp_absolute_path "clang-llvm-${LLVM_VERSION}-osx-binary")" \
               build_osx
  ;;
  linux)
    with_pushd "$(mkdirp_absolute_path "clang-llvm-${LLVM_VERSION}-linux")" \
               build_linux "$(validate_cmake)"
  ;;
  *)
    die "clang does not support building for '${TARGET_PLATFORM}'"
    ;;
esac
