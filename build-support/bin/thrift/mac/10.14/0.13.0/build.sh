#!/bin/bash

readonly result="$(./build-thrift.sh 0.13.0 3.2 20140715)"
cp "$result" ./thrift
