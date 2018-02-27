#!/bin/bash -eu

for plat in "cmake-3.9.5-Darwin-x86_64" "cmake-3.9.5-Linux-x86_64"; do
  curl -O "https://cmake.org/files/v3.9/${plat}.tar.gz"
  rm -rf "${plat}"
  tar xzf "${plat}.tar.gz"
done

# Initial copies for macOS and Linux.
MACOS_BASE="$(pwd)/build-support/bin/cmake/mac/10.7/3.9.5"
mkdir -p "${MACOS_BASE}"
tar -C cmake-3.9.5-Darwin-x86_64/CMake.app/Contents -czf "${MACOS_BASE}/cmake.tar.gz" bin share

LINUX_BASE="$(pwd)/build-support/bin/cmake/linux/x86_64/3.9.5"
mkdir -p "${LINUX_BASE}"
tar -C cmake-3.9.5-Linux-x86_64 -czf "${LINUX_BASE}/cmake.tar.gz" bin share

# Additional symlinks for macOS.
for rev in "10.8" "10.9" "10.10" "10.11" "10.12" "10.13"; do
  DEST_BASE="build-support/bin/cmake/mac/${rev}"
  mkdir -p "${DEST_BASE}"
  pushd "${DEST_BASE}" > /dev/null
  ln -sf "../10.7/3.9.5" "3.9.5"
  popd > /dev/null
done
