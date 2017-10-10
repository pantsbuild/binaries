#!/bin/bash
 
set -e

for plat in "cmake-3.8.2-Darwin-x86_64" "cmake-3.8.2-Linux-x86_64"; do
  curl -O "https://cmake.org/files/v3.8/${plat}.tar.gz"
  rm -rf "${plat}"
  tar xzf "${plat}.tar.gz"
done

# Initial copies for macOS and Linux.
MACOS_BASE="build-support/bin/cmake/mac/10.7/3.8.2"
mkdir -p "${MACOS_BASE}"
cp "cmake-3.8.2-Darwin-x86_64/CMake.app/Contents/bin/cmake" "${MACOS_BASE}"

LINUX_BASE="build-support/bin/cmake/linux/x86_64/3.8.2"
mkdir -p "${LINUX_BASE}"
cp "cmake-3.8.2-Linux-x86_64/bin/cmake" "${LINUX_BASE}"

# Additional symlinks for macOS.
for rev in "10.8" "10.9" "10.10" "10.11" "10.12" "10.13"; do
  DEST_BASE="build-support/bin/cmake/mac/${rev}"
  mkdir -p "${DEST_BASE}"
  pushd "${DEST_BASE}" > /dev/null
    ln -s "../10.7/3.8.2" "3.8.2"
  popd > /dev/null
done
