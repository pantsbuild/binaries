#!/bin/bash -exu

# Build Node.js for just this version and architecture.
NODE_VERSION="v8.11.3"
ARCH="darwin-x64"

tarball_name="node-${NODE_VERSION}-${ARCH}"

# Make it easy to use gnu-tar on Mac, since the default bsdtar that comes with OS X 
# is not compatible with gnu-tar.
TAR_CMD="${TAR_CMD:-tar}"
echo "Using tar command '${TAR_CMD}'"

curl -O https://nodejs.org/dist/${NODE_VERSION}/${tarball_name}.tar.gz

# Unpack and repack
rm -rf unpack && mkdir unpack && \
${TAR_CMD} -xzf ${tarball_name}.tar.gz -C unpack && \
rm ${tarball_name}.tar.gz && \
mv unpack/${tarball_name} unpack/node && \
${TAR_CMD} -czf node.tar.gz -C unpack node/ && \
rm -rf unpack
