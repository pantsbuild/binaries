#!/bin/bash

readonly result="$(./build-gcc osx 7.3.0)"

cp "$result" build-support/bin/gcc/mac/10.13/7.3.0/gcc.tar.gz
