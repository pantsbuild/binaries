#!/bin/bash

readonly result="$(./build-thrift.sh 0.14.2 3.2 20140715)"
cp "$result" ./thrift
