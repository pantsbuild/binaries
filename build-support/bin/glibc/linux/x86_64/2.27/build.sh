#!/bin/bash

yum -y install m4
yum -y install xz

readonly bison_dir="$(RETURN_ARCHIVE=no ./build-bison.sh linux 3.0.5)"

readonly glibc_archive="$(./build-glibc.sh linux 2.27 "$bison_dir")"

cp "$glibc_archive" ./glibc.tar.gz
