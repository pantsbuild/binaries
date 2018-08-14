#!/bin/bash -exu

YARNPKG_VERSION="v1.6.0"

tarball_name="yarn-${YARNPKG_VERSION}"

# Make it easy to use gnu-tar on Mac, since the default bsdtar that comes with OS X 
# is not compatible with gnu-tar.
TAR_CMD="${TAR_CMD:-tar}"
echo "Using tar command '${TAR_CMD}'"

curl -L -O https://github.com/yarnpkg/yarn/releases/download/${YARNPKG_VERSION}/${tarball_name}.tar.gz

# Unpack and repack according to Pants runtime expectation.
rm -rf unpack && mkdir unpack && \
${TAR_CMD} -xzf ${tarball_name}.tar.gz -C unpack && \
rm ${tarball_name}.tar.gz && \
mv unpack/${tarball_name} unpack/dist && \
${TAR_CMD} -czf yarnpkg.tar.gz -C unpack dist/ && \
rm -rf unpack
