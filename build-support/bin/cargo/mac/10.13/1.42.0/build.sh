#!/bin/bash

readonly result="$(./build-cargo.sh 1.42.0 0.2.1)"

cp "$result" ./cargo.tar.gz
