#!/bin/bash

yum -y install xz

readonly result="$(./build-binutils.sh linux 2.30)"

cp "$result" ./binutils.tar.gz
