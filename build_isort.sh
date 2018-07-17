#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
source "${ROOT}/run_pex.bash"

if (( $# != 1 )); then
  echo "Usage: $0 <isort version>"
  exit 1
fi

version="$1"

target="${ROOT}/build-support/bin/isort/${version}/isort.pex"

# Two things of note:
# 1. We force isort to be built for python2.7 since Pants will be running on 2.7.
# 2. The isort code has a dependency on setuptools but it is not declared, so we do so here.
run_pex -v \
  --python=python2.7 \
  "isort==${version}" \
  setuptools \
  -c isort \
  -o "${target}"

"${target}" --version

