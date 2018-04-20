#!/bin/bash

yum -y install xz

readonly result="$(./build-llvm-for-linux-with-cmake.sh 6.0.0)"

cp "$result" ./llvm.tar.gz
