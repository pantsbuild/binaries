#!/bin/bash -exuo pipefail

VERSION=${1:-"v1.2.0"}

CURRENT_MAC_VERSION="10.13"

ADDITIONAL_MAC_VERSIONS=(
  10.6
  10.7
  10.8
  10.9
  10.10
  10.11
  10.12
)

ARCH_DIRECTORIES=(
  linux/x86_64
  mac/${CURRENT_MAC_VERSION}
)

function build_yarnpkg()
{
  # Unpack and repack according to Pants runtime expectation.
  rm -rf unpack && mkdir unpack && \
  ${TAR_CMD} -xzf yarn-${VERSION}.tar.gz -C unpack && \
  rm yarn-${VERSION}.tar.gz && \
  mv unpack/yarn-${VERSION} unpack/dist && \
  ${TAR_CMD} -czf yarn-temp.tar.gz -C unpack dist/ && \
  rm -rf unpack && \
  mv -f yarn-temp.tar.gz yarnpkg-${VERSION}.tar.gz
}

# Make it easy to use gnu-tar on Mac, since the default bsdtar that comes with OS X is not
# compatible with gnu-tar.
TAR_CMD="${TAR_CMD:-tar}"
echo "Using tar command '${TAR_CMD}'"

wget https://github.com/yarnpkg/yarn/releases/download/${VERSION}/yarn-${VERSION}.tar.gz
build_yarnpkg

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
