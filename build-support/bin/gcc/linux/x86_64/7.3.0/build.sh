#!/bin/bash

yum -y install wget m4 xz

readonly result="$(./build-gcc.sh linux 7.3.0)"

cp "$result" ./gcc.tar.gz
