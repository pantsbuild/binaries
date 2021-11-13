#!/bin/bash

yum install -y flex flex-devel

readonly result="$(./build-thrift.sh 0.14.2 2.5.1 20140715)"
cp "$result" ./thrift
