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

DESTINATION_DIRECTORIES=(
  linux/i386
  linux/x86_64
  mac/${CURRENT_MAC_VERSION}
)


wget https://github.com/yarnpkg/yarn/releases/download/${VERSION}/yarn-${VERSION}.tar.gz
mv yarn-${VERSION}.tar.gz yarnpkg-${VERSION}.tar.gz

for ((i = 0; i < ${#DESTINATION_DIRECTORIES[@]}; i++))
do
  echo "Copying tar for yarnpkg ${VERSION}, ${DESTINATION_DIRECTORIES[$i]}..."
  full_dest_dir="build-support/bin/yarnpkg/${DESTINATION_DIRECTORIES[$i]}/${VERSION}"
  mkdir -p ${full_dest_dir}
  cp yarnpkg-${VERSION}.tar.gz "${full_dest_dir}/yarnpkg.tar.gz"
done
rm "yarnpkg-${VERSION}.tar.gz"

function create_mac_version_symlink() {
  local node_version=$1
  local source_mac_version=$2
  local dest_mac_version=$3
  local symlink_dir="build-support/bin/yarnpkg/mac/${dest_mac_version}/${node_version}"
  local symlink_path="${symlink_dir}/yarnpkg.tar.gz"

  mkdir -p ${symlink_dir} && \
    rm -f ${symlink_path} && \
    ln -s ../../${source_mac_version}/${node_version}/yarnpkg.tar.gz ${symlink_path}
}

for additional_mac_version in "${ADDITIONAL_MAC_VERSIONS[@]}"
do
  echo "Creating symlink for yarnpkg ${VERSION}, ${DESTINATION_DIRECTORIES[$i]}..."
  create_mac_version_symlink ${VERSION} ${CURRENT_MAC_VERSION} ${additional_mac_version}
done
