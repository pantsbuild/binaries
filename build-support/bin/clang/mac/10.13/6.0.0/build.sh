#!/bin/bash

readonly result="$(./build-clang.sh osx 6.0.0)"

cp "$result" build-support/bin/clang/mac/10.13/6.0.0/clang.tar.gz
