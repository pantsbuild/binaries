#!/bin/bash

readonly result="$(./build-clang.sh osx 5.0.1)"

cp "$result" build-support/bin/clang/mac/10.13/5.0.1/clang.tar.gz
