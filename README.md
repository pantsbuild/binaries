binaries
========

A home for scripts that build pants static binaries.

workflow
========

The general workflow for publishing new binaries is:

1. Create a script that will build the binary tool for both Linux and OSX (as reproducibly as
   possible).
2. Get the script reviewed. During review, the reviewer should confirm that the script
   successfully produces binaries on their machine(s).
3. The script should then be merged _without_ the produced binaries.
4. After merging, the reviewer should (re-)execute the script (if necessary), and then run:
     ```
     ./sync-s3.sh
     ```
  ...to sync the produced binaries to s3.

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

