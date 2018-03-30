#!/bin/bash

readonly result="$(./build-binutils.sh linux 2.30)"

cp "$result" build-support/bin/binutils/linux/x86_64/2.30/binutils.tar.gz
