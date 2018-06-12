#!/bin/bash

readonly result="$(./build-xz.sh osx 5.2.4)"

cp "$result" ./xz.tar.gz
