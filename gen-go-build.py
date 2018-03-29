#!/usr/bin/python

# Helper for creating Go build.sh files. This script will create a default build.sh file
# for Go/macOS/Linux versions listed below, unless the directory already exists. If a custom
# build.sh script is needed, just create it and this helper will ignore it going forward.

import os
from textwrap import dedent

go_versions = [
    '1.9.4',
    '1.10',
]

mac_versions = [
    '10.8',
    '10.9',
    '10.10',
    '10.11',
    '10.12',
    '10.13',
]

tmpl = dedent("""\
    #!/bin/bash
    set -o xtrace
    curl https://storage.googleapis.com/golang/go{go_version}.{arch}.tar.gz -o go.tar.gz
    """)

def maybe_gen(dir, go_version, arch):
    if not os.path.exists(dir):
        os.makedirs(dir)
        filename = os.path.join(dir, 'build.sh')
        with open(filename, 'w') as fh:
            fh.write(tmpl.format(go_version=go_version, arch=arch))
        os.chmod(filename, 0755)

def mac():
    for mac_version in mac_versions:
        for go_version in go_versions:
            dir = 'build-support/bin/go/mac/%s/%s' % (mac_version, go_version)
            maybe_gen(dir, go_version, 'darwin-amd64')

def x86_64():
    for go_version in go_versions:
        dir = 'build-support/bin/go/linux/x86_64/%s' % go_version
        maybe_gen(dir, go_version, 'linux-amd64')

mac()
x86_64()
