#!/bin/bash

readonly result="$(./build-llvm.sh linux 6.0.0)"

cp "$result" ./llvm.tar.xz
