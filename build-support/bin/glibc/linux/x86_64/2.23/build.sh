#!/bin/bash

yum -y install m4 xz

readonly bison_dir="$(RETURN_ARCHIVE=no ./build-bison.sh linux 3.0.5)"

# NB: 2.23 is the latest version compatible with centos6's kernel version.
readonly glibc_archive="$(./build-glibc.sh linux 2.23 "$bison_dir")"

cp "$glibc_archive" ./glibc.tar.gz
