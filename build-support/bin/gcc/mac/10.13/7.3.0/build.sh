#!/bin/bash

readonly result="$(./build-gcc.sh osx 7.3.0)"

cp "$result" ./gcc.tar.gz
