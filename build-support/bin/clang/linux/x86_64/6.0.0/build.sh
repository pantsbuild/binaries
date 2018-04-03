#!/bin/bash

yum -y install xz

readonly result="$(./build-clang-for-linux-with-cmake.sh 6.0.0)"

cp "$result" ./clang.tar.gz
