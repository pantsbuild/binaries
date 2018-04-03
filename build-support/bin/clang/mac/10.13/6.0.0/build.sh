#!/bin/bash

readonly result="$(./build-clang.sh osx 6.0.0)"

cp "$result" ./clang.tar.gz
