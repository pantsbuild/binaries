#!/bin/bash

readonly result="$(./build-llvm.sh osx 6.0.0)"

cp "$result" ./llvm.tar.xz
