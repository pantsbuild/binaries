binaries
========

A home for scripts that build pants static binaries.


Supported Platforms
===================

As of Spring 2018, binaries are no longer being published for i386 nor macOS versions prior to 10.8.
Binaries for Linux x86_64 and macOS 10.8+ are generally published.

workflow
========

The general workflow for publishing new binaries is:

1. Create a script that will build the binary tool as reproducibly as possible, and place
   it in a relevant directory under `build-support`. For example, for `thrift` `0.10.0` for `osx`,
   you'd create the script at `build-support/bin/thrift/mac/10.13/0.10.0/build.sh`.
2. Symlink the script directory into all other relevant versions for both platforms. For OSX, this
   will generally include "all modern OSX versions": ie,
   `build-support/bin/thrift/mac/{10.13,10.12,10.11,10.10,etc}`.
3. Get the script and links reviewed. During review, the reviewer should confirm that the script
   successfully produces a binary on their machine(s).
4. The script should then be merged _without_ the produced binaries.
5. After merging, the reviewer should (re-)execute the script (if necessary), confirm that binaries
   have been created in all relevant symlinked directories, and then run:
     ```
     ./sync-s3.sh
     ```
  ...to upload the produced binaries to s3.

building
========

linux
-----

Requires [docker](https://www.docker.com/)

1. Change directories to the root of this repository.
  ```
  docker run -v "$(pwd):/pantsbuild-binaries" --rm -it --entrypoint /bin/bash pantsbuild/centos6:latest && cd /pantsbuild-binaries
  ```
  ...to pop yourself in a controlled image back at this repo's root
2. Run the build-\*.sh script corresponding to the binary you wish to build
3. Manually move the binary from the build tree to its home in build-support/...

osx
---

We have no controlled build environment solution like we do for linux, so you'll need to get your hands on an OSX machine.  With that in hand:

1. Run the build-\*.sh script corresponding to the binary you wish to build
2. manually move the binary from the build tree to its home in build-support/...

