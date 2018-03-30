#!/bin/bash

yum -y install wget m4 xz

readonly result="$(./build-gcc.sh linux 7.3.0)"

cp "$result" build-support/bin/gcc/linux/x86_64/7.3.0/gcc.tar.gz
