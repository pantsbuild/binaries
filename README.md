binaries
========

A temporary home for pants static binaries and scripts

building
========

linux
-----

Requires [docker](https://www.docker.com/)

+ Change directories to the root of this repository.
+ `docker run -v `pwd`:/pantsbuild-binaries -it --entrypoint /bin/bash python:2.7.13-wheezy && cd /pantsbuild-binaries` to pop yourself in a controlled image back at this repo's root
+ Run the build-\*.sh script corresponding to the binary you wish to build
+ Manually move the binary from the build tree to its home in build-support/...

osx
---

We have no controlled build environment solution like we do for linux, so you'll need to get your hands on an OSX machine.  With that in hand:

Requires `libtool`, `gettext`, `autoconf` (for flex)

N.B. Homebrew will install `gettext` but will not add it to your path.

      export PATH=${PATH}:/usr/local/opt/gettext/bin

+ Run the build-\*.sh script corresponding to the binary you wish to build
+ manually move the binary from the build tree to its home in build-support/...
