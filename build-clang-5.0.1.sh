#!/bin/bash

if ! hash xz; then
  cat >&2 <<EOF
'xz' is required to run this script. You may have to install it using your
operating system's package manager.
EOF
  exit 1
fi

set -euxo pipefail

LLVM_VERSION='5.0.1'
CORRESPONDING_CLANG_BIN_VERSION='5.0'
LLVM_RELEASE_BUILD_DIRNAME='llvm-tmp'
LLVM_PANTS_ARCHIVE_NAME='clang.tar.gz'
CLANG_SUPPORTDIR='build-support/bin/clang'

mkdir -p "$LLVM_RELEASE_BUILD_DIRNAME"

CLANG_BINARIES=(
  clang
  clang++
  clang-"${CORRESPONDING_CLANG_BIN_VERSION}"
)

function extract-required-files-from-unpacked-llvm {
  local -r unpacked_llvm_dir="$1"
  local -r pants_output_archive_name="$2"

  mkdir -p bin/ include/

  for bin_path in ${CLANG_BINARIES[@]}; do
    cp "${unpacked_llvm_dir}/bin/${bin_path}" bin/
  done

  # Copy over the C standard library headers into the include/ subdir. We will
  # include the C++ standard library headers in a separate subdirectory in a
  # future commit.
  find "$unpacked_llvm_dir"/lib/clang/"$LLVM_VERSION"/include \
       -type f \
       -name '*.h' \
       -exec cp '{}' include/ ';'

  tar czf "$pants_output_archive_name" bin/ include/
}


## MacOS (LLVM-packaged release binaries)
MACOS_REVS=(
  10.7
  10.8
  10.9
  10.10
  10.11
  10.12
  10.13
)
LLVM_TMP_MACOS_PKG_DIR='llvm-macos-pkg'

pushd "$LLVM_RELEASE_BUILD_DIRNAME"

curl -L -O "https://releases.llvm.org/${LLVM_VERSION}/clang+llvm-${LLVM_VERSION}-x86_64-apple-darwin.tar.xz"
tar xf "clang+llvm-${LLVM_VERSION}-x86_64-apple-darwin.tar.xz"
llvm_macos_bin_release_dir_abs="$(pwd)/clang+llvm-${LLVM_VERSION}-final-x86_64-apple-darwin"

mkdir -p "$LLVM_TMP_MACOS_PKG_DIR"
pushd "$LLVM_TMP_MACOS_PKG_DIR"

extract-required-files-from-unpacked-llvm \
  "$llvm_macos_bin_release_dir_abs" \
  "$LLVM_PANTS_ARCHIVE_NAME"

llvm_macos_packaged_abs="$(pwd)/${LLVM_PANTS_ARCHIVE_NAME}"
popd

popd

for rev in ${MACOS_REVS[@]}; do
  dest_base="${CLANG_SUPPORTDIR}/mac/${rev}/${LLVM_VERSION}"
  mkdir -p "$dest_base"
  cp "$llvm_macos_packaged_abs" "${dest_base}/${LLVM_PANTS_ARCHIVE_NAME}"
done


## Linux (from source release)
# We need cmake >= 3.4, so use the one we already build for pants.
CMAKE_VERSION='3.9.5'
CMAKE_BUILD_TMP_DIR='cmake-build-tmp'
LLVM_BUILD_TMP_DIR='llvm-build'
LLVM_TMP_LINUX_PKG_DIR='llvm-linux-pkg'

"./build-cmake-${CMAKE_VERSION}.sh"
cmake_linux_packaged_abs="$(pwd)/build-support/bin/cmake/linux/x86_64/${CMAKE_VERSION}/cmake.tar.gz"

mkdir -p "$CMAKE_BUILD_TMP_DIR"
pushd "$CMAKE_BUILD_TMP_DIR"
tar zxf "$cmake_linux_packaged_abs"
cmake_linux_bin_abs="$(pwd)/bin/cmake"
popd

pushd "$LLVM_RELEASE_BUILD_DIRNAME"

# LLVM requires you to download the source for LLVM and the Clang frontend
# separately. The alternative is checking out their SVN repo, which takes much
# longer.
curl -L -O "https://releases.llvm.org/${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.xz"
curl -L -O "https://releases.llvm.org/${LLVM_VERSION}/cfe-${LLVM_VERSION}.src.tar.xz"
tar xf "llvm-${LLVM_VERSION}.src.tar.xz"
tar xf "cfe-${LLVM_VERSION}.src.tar.xz"

mkdir -p "$LLVM_BUILD_TMP_DIR"
pushd "$LLVM_BUILD_TMP_DIR"

"$cmake_linux_bin_abs" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_EXTERNAL_CLANG_SOURCE_DIR="../cfe-${LLVM_VERSION}.src" \
  -DLLVM_EXTERNAL_PROJECTS='clang' \
  "../llvm-${LLVM_VERSION}.src"

# NB: There appear to be race conditions when running make with any parallelism
# here in a Docker image.
make

llvm_linux_source_release_dir_abs="$(pwd)"

popd

mkdir -p "$LLVM_TMP_LINUX_PKG_DIR"
pushd "$LLVM_TMP_LINUX_PKG_DIR"

extract-required-files-from-unpacked-llvm \
  "$llvm_linux_source_release_dir_abs" \
  "$LLVM_PANTS_ARCHIVE_NAME"

llvm_linux_packaged_abs="$(pwd)/${LLVM_PANTS_ARCHIVE_NAME}"

popd

popd

mkdir -p "${CLANG_SUPPORTDIR}/linux/x86_64/${LLVM_VERSION}"
cp "$llvm_linux_packaged_abs" "${CLANG_SUPPORTDIR}/linux/x86_64/${LLVM_VERSION}/${LLVM_PANTS_ARCHIVE_NAME}"
