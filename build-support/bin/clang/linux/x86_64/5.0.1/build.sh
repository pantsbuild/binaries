#!/bin/bash

yum -y install xz

readonly result="$(./build-clang-for-linux-with-cmake.sh 5.0.1)"

cp "$result" build-support/bin/clang/linux/x86_64/5.0.1/clang.tar.gz
