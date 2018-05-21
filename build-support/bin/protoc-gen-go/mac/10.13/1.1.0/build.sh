#!/bin/bash

FILENAME=${BASH_SOURCE[0]}
DIR=$( cd "$( dirname "${FILENAME}" )" && pwd )
export GOPATH=$DIR
go get -u github.com/golang/protobuf/protoc-gen-go
mv ${DIR}/bin/protoc-gen-go $DIR
rmdir ${DIR}/bin
rm -rf ${DIR}/src

