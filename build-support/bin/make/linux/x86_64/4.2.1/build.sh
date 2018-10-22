#!/bin/bash

readonly result="$(./build-make.sh 4.2.1)"

cp "$result" ./make.tar.gz
