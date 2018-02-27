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
LLVM_PANTS_ARCHIVE_NAME='compiler.tar.gz'
COMPILER_SUPPORTDIR='build-support/bin/compiler'

# default to -j2
MAKE_JOBS="${MAKE_JOBS:-2}"

mkdir -p "$LLVM_RELEASE_BUILD_DIRNAME"


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

pushd "$LLVM_RELEASE_BUILD_DIRNAME"

curl -L -O "https://releases.llvm.org/${LLVM_VERSION}/clang+llvm-${LLVM_VERSION}-x86_64-apple-darwin.tar.xz"
tar xf "clang+llvm-${LLVM_VERSION}-x86_64-apple-darwin.tar.xz"
pushd "clang+llvm-${LLVM_VERSION}-final-x86_64-apple-darwin"
tar czf "$LLVM_PANTS_ARCHIVE_NAME" \
    bin/clang \
    bin/clang++ \
    "bin/clang-${CORRESPONDING_CLANG_BIN_VERSION}"
llvm_macos_packaged_abs="$(pwd)/${LLVM_PANTS_ARCHIVE_NAME}"
popd

popd

for rev in ${MACOS_REVS[@]}; do
  dest_base="${COMPILER_SUPPORTDIR}/mac/${rev}/${LLVM_VERSION}"
  mkdir -p "$dest_base"
  cp "$llvm_macos_packaged_abs" "${dest_base}/${LLVM_PANTS_ARCHIVE_NAME}"
done


## Linux (from source release)
# We need cmake >= 3.4, so use the one we already build for pants.
CMAKE_VERSION='3.9.5'
CMAKE_BUILD_TMP_DIR='cmake-build-tmp'
LLVM_BUILD_TMP_DIR='llvm-build'
LLVM_TMP_PKG_DIR='llvm-pkg'

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

make -j"$MAKE_JOBS"

llvm_built_dir_abs="$(pwd)"

popd

mkdir -p "$LLVM_TMP_PKG_DIR"
pushd "$LLVM_TMP_PKG_DIR"

mkdir -p include/
cp "$llvm_built_dir_abs"/lib/clang/"${LLVM_VERSION}"/include/*.h include/

mkdir -p bin/
cp "$llvm_built_dir_abs"/bin/{clang,clang++,clang-"${CORRESPONDING_CLANG_BIN_VERSION}"} bin/

tar cvzf "$LLVM_PANTS_ARCHIVE_NAME" bin include

llvm_linux_packaged_abs="$(pwd)/${LLVM_PANTS_ARCHIVE_NAME}"

popd

popd

mkdir -p "${COMPILER_SUPPORTDIR}/linux/x86_64/${LLVM_VERSION}"
cp "$llvm_linux_packaged_abs" "${COMPILER_SUPPORTDIR}/linux/x86_64/${LLVM_VERSION}/${LLVM_PANTS_ARCHIVE_NAME}"
