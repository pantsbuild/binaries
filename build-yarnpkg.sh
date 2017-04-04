#!/bin/bash -exuo pipefail

VERSION=${1:-"v0.19.1"}

CURRENT_MAC_VERSION="10.12"

ADDITIONAL_MAC_VERSIONS=(
  10.6
  10.7
  10.8
  10.9
  10.10
  10.11
)

ARCH_DIRECTORIES=(
  linux/i386
  linux/x86_64
  mac/${CURRENT_MAC_VERSION}
)


wget https://github.com/yarnpkg/yarn/releases/download/${VERSION}/yarn-${VERSION}.tar.gz
mv yarn-${VERSION}.tar.gz yarnpkg-${VERSION}.tar.gz

for arch_directory in ${ARCH_DIRECTORIES[@]}
do
  echo "Copying tar for yarnpkg ${VERSION}, ${arch_directory}..."
  full_dest_dir="build-support/bin/yarnpkg/${arch_directory}/${VERSION}"
  mkdir -p ${full_dest_dir}
  cp -f ./yarnpkg-${VERSION}.tar.gz ${full_dest_dir}/yarnpkg.tar.gz
done

for additional_mac_version in "${ADDITIONAL_MAC_VERSIONS[@]}"
do
  echo "Creating symlink for yarnpkg ${VERSION}, ${additional_mac_version}..."
  full_symlink_dir="build-support/bin/yarnpkg/mac/${additional_mac_version}/${VERSION}"
  mkdir -p ${full_symlink_dir}
  ln -fs ../../${CURRENT_MAC_VERSION}/${VERSION}/yarnpkg.tar.gz ${full_symlink_dir}/yarnpkg.tar.gz
done

rm "yarnpkg-${VERSION}.tar.gz"
