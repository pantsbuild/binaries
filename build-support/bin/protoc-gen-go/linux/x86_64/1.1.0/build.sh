#!/bin/bash

FILENAME=${BASH_SOURCE[0]}
DIR=$( cd "$( dirname "${FILENAME}" )" && pwd )

curl -LO https://storage.googleapis.com/golang/go1.10.2.linux-amd64.tar.gz
tar -xf go1.10.2.linux-amd64.tar.gz

export GOROOT=${DIR}/go
export GOPATH=$DIR
export PATH=${PATH}:${GOROOT}/bin

go get -u github.com/golang/protobuf/protoc-gen-go
mv ${DIR}/bin/protoc-gen-go $DIR
rm -rf ${DIR}/go*
rmdir ${DIR}/bin
rm -rf ${DIR}/src

