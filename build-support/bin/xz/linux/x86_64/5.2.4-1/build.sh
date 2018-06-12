#!/bin/bash

readonly result="$(./build-xz.sh linux 5.2.4)"

cp "$result" ./xz.tar.gz
