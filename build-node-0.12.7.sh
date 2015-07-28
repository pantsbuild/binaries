#!/bin/sh


#curl -O https://nodejs.org/dist/v0.12.7/node-v0.12.7.tar.gz && \
#rm -rf node-v0.12.7 && \
#tar -xzf node-v0.12.7.tar.gz && \
cd node-v0.12.7 && \
./configure --prefix=./ && make && make install
