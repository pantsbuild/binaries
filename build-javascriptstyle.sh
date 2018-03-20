#!/bin/bash -exuo pipefail

PACKAGE="javascriptstyle"
PACKAGE_NAME="javascriptstyle.tgz"
SOURCE_LOCATION="build-support/scripts/javascriptstyle/src"
VERSION=$(cat ${SOURCE_LOCATION}/${PACKAGE}/package.json | jq .version | sed -e 's/^"//'  -e 's/"$//')

# Make it easy to use gnu-tar on Mac, since the default bsdtar that comes with OS X is not
# compatible with gnu-tar.
TAR_CMD="${TAR_CMD:-tar}"
echo "Using tar command '${TAR_CMD}'"

FULL_DEST_DIR="build-support/scripts/javascriptstyle/releases/${VERSION}"
mkdir -p ${FULL_DEST_DIR}

${TAR_CMD} -cvzf ${PACKAGE_NAME} -C ${SOURCE_LOCATION} ${PACKAGE}

cp -f ./${PACKAGE_NAME} ${FULL_DEST_DIR}/${PACKAGE_NAME}

rm -f ${PACKAGE_NAME}