binaries
========

A temporary home for pants static binaries and scripts

building
========

linux
-----

Requires [vagrant](https://www.vagrantup.com/)

+ Change directories to the target arch.
+ `vagrant up && vagrant ssh && cd /vagrant_data` to pop yourself in a controlled image back at this repo's root
+ Run the build-\*.sh script corresponding to the binary you wish to build
+ manually move the binary from the build tree to its home in build-support/...

osx
---

We have no controlled build environment solution like we do for linux, so you'll need to get your hands on an OSX machine.  With that in hand:

+ Run the build-\*.sh script corresponding to the binary you wish to build
+ manually move the binary from the build tree to its home in build-support/...
