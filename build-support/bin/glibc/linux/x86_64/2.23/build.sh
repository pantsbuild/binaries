#!/bin/bash

yum -y install xz

# NB: 2.23 is the latest version compatible with centos6's kernel version.
readonly glibc_archive="$(./build-glibc.sh linux 2.23)"

cp "$glibc_archive" ./glibc.tar.gz
