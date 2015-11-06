#!/bin/sh

ARCHS=(
  osx-x86_64
  linux-i386
  linux-x86_64
)

REV=0.1.6.0

for arch in ${ARCHS[@]}
do
  curl -L -O https://github.com/commercialhaskell/stack/releases/download/v${REV}/stack-${REV}-${arch}.tar.gz
done
