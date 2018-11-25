#!/bin/sh

# Also the tag
VERSION=$1

DEST_JAR_NAME="coursier-cli-${VERSION}.jar"
DEST_DIR="build-support/bin/coursier/${VERSION}/"

rm -rf coursier && \
git clone https://github.com/coursier/coursier.git && \
pushd coursier && \
git checkout -f ${VERSION} && \
./pants binary cli/src/main/scala-2.12:coursier-cli && \
popd && \
mkdir -p ${DEST_DIR} && \
mv coursier/dist/coursier-cli.jar "${DEST_DIR}/${DEST_JAR_NAME}"
