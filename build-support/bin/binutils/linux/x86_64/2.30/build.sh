#!/bin/bash

readonly result="$(./build-binutils.sh linux 2.30)"

cp "$result" ./binutils.tar.gz
