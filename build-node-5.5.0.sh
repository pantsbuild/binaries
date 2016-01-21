#!/bin/sh

VERSION="v5.5.0"

# ARCHES and DESTINATION_DIRECTORIES must be the same length.
# They are, respectively, the arch names used in tar files from nodejs.org,
# and the local destination directories for each arch.
ARCHES=(
  linux-x86
  linux-x64
  darwin-x64
)
DESTINATION_DIRECTORIES=(
  linux/i386
  linux/x86_64
  mac/10.11
)

CURRENT_MAC_VERSION="10.11"

ADDITIONAL_MAC_VERSIONS=(
  10.6
  10.7
  10.8
  10.9
  10.10
)

function build_node() {
  local version=$1
  local arch=$2
  local name="node-${version}-${arch}"

  curl -O https://nodejs.org/dist/${version}/${name}.tar.gz && \
    rm -rf unpack && mkdir unpack && \
    tar -xzf ${name}.tar.gz -C unpack && \
    mv unpack/${name} unpack/node && \
    tar -czf node.tar.gz -C unpack node/ && \
    mv node.tar.gz ${name}.tar.gz
}

function copy_built_node_into_place() {
  local version=$1
  local arch=$2
  local dest_dir=$3
  local name="node-${version}-${arch}"
  local full_dest_dir="build-support/bin/node/${dest_dir}/${version}"

  rm -rf ${full_dest_dir} && \
    mkdir -p "${full_dest_dir}" && \
    cp ${name}.tar.gz "${full_dest_dir}/node.tar.gz"
}

function create_mac_version_symlink() {
  local node_version=$1
  local source_mac_version=$2
  local dest_mac_version=$3
  local symlink_dir="build-support/bin/node/mac/${dest_mac_version}/${node_version}"
  local symlink_path="${symlink_dir}/node.tar.gz"

  mkdir -p ${symlink_dir} && \
    rm -f ${symlink_path} && \
    ln -s ../../${source_mac_version}/${node_version}/node.tar.gz ${symlink_path}
}

for ((i = 0; i < ${#ARCHES[@]}; i++))
do
  build_node ${VERSION} ${ARCHES[$i]}
  copy_built_node_into_place ${VERSION} ${ARCHES[$i]} ${DESTINATION_DIRECTORIES[$i]}
  rm "node-${VERSION}-${ARCHES[$i]}.tar.gz"
done

rm -rf unpack

for additional_mac_version in "${ADDITIONAL_MAC_VERSIONS[@]}"
do
  create_mac_version_symlink ${VERSION} ${CURRENT_MAC_VERSION} ${additional_mac_version}
done
