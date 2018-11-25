#!/bin/sh

# Also the tag
VERSION=$1

DEST_JAR_NAME="coursier-cli-${VERSION}.jar"
DEST_DIR="build-support/bin/coursier/${VERSION}/"

TEMPDIR="/tmp/coursier"
rm -rf ${TEMPDIR} && \
mkdir -p ${TEMPDIR} && \
git clone https://github.com/coursier/coursier.git ${TEMPDIR} && \
pushd ${TEMPDIR} && \
git checkout -f ${VERSION} && \
./pants binary cli/src/main/scala-2.12:coursier-cli && \
popd && \
mkdir -p ${DEST_DIR} && \
mv ${TEMPDIR}/dist/coursier-cli.jar ${DEST_JAR_NAME}
