#!/bin/bash

yum -y install xz

readonly result="$(./build-glibc.sh linux 2.27)"

cp "$result" ./glibc.tar.gz
