#!/bin/sh

VERSION="v6.9.1"

CURRENT_MAC_VERSION="10.12"

ADDITIONAL_MAC_VERSIONS=(
  10.6
  10.7
  10.8
  10.9
  10.10
  10.11
)

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
  mac/${CURRENT_MAC_VERSION}
)

# Make it easy to use gnu-tar on Mac, since the default bsdtar that comes with OS X is not
# compatible with gnu-tar.
TAR_CMD="${TAR_CMD:-tar}"
echo "Using tar command '${TAR_CMD}'"

function build_node() {
  local version=$1
  local arch=$2
  local name="node-${version}-${arch}"

  curl -O https://nodejs.org/dist/${version}/${name}.tar.gz && \
    rm -rf unpack && mkdir unpack && \
    ${TAR_CMD} -xzf ${name}.tar.gz -C unpack && \
    mv unpack/${name} unpack/node && \
    ${TAR_CMD} -czf node.tar.gz -C unpack node/ && \
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
  echo "Building tar for Node ${VERSION}, ${ARCHES[$i]}..."
  build_node ${VERSION} ${ARCHES[$i]}
  copy_built_node_into_place ${VERSION} ${ARCHES[$i]} ${DESTINATION_DIRECTORIES[$i]}
  rm "node-${VERSION}-${ARCHES[$i]}.tar.gz"
done

rm -rf unpack

for additional_mac_version in "${ADDITIONAL_MAC_VERSIONS[@]}"
do
  create_mac_version_symlink ${VERSION} ${CURRENT_MAC_VERSION} ${additional_mac_version}
done
