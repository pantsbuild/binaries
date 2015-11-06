#!/bin/sh

ARCHS=(
  osx-x86_64
  linux-i386
  linux-x86_64
)

REV=0.1.6.0

DOWNLOAD_BASE_URL=https://github.com/commercialhaskell/stack/releases/download

function build_stack() {
  local version=$1
  local arch=$2
  local name="stack-${version}-${arch}"

  curl -L -O ${DOWNLOAD_BASE_URL}/v${version}/${name}.tar.gz && \
    rm -rf unpack && mkdir unpack && \
    tar -xzf ${name}.tar.gz -C unpack && \
    mv unpack/${name} unpack/stack && \
    tar -czf stack.tar.gz -C unpack stack/ && \
    mv stack.tar.gz ${name}.tar.gz
}

for arch in ${ARCHS[@]}
do
  build_stack ${REV} ${arch}
done
