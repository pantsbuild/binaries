#!/bin/sh

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

ARCHES=(
  linux-x86
  linux-x64
  darwin-x64
)

for arch in "${ARCHES[@]}"
do
  build_node v4.0.0 ${arch}
done
