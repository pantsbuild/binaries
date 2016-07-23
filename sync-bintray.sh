#!/usr/bin/env bash

API_HOST=api.bintray.com

ORG=pantsbuild
REPOSITORY=bin
PACKAGE=pants-support-binaries
VERSION=0.0.5

REPO_KEY="${ORG}/${REPOSITORY}/${PACKAGE}"

function check_netrc {
  [[ -f ~/.netrc && -n "$(grep -E "^\s*machine\s+${API_HOST}\s*$" ~/.netrc)" ]]
}

if ! check_netrc
then
  echo "In order to publish bintray binaries you need an account"
  echo "with membership in the ${ORG} org [1]."
  echo
  echo "This account will need to be added to a ~/.netrc entry as follows:"
  echo 
  echo "machine ${API_HOST}"
  echo "  login <bintray username>"
  echo "  password <bintray api key [2]>"
  echo
  echo "[1] https://bintray.com/${ORG}"
  echo "[2] https://bintray.com/docs/interacting/interacting_apikeys.html"
  exit 1
fi

echo -e "Determining which artifacts to upload to:\n  https://dl.bintray.com/${ORG}/${REPOSITORY}"
echo

function hash_local_files() {
  git ls-files | \
  grep -v -E '.sha1$' | \
  xargs openssl sha1 | \
  sed -E "s/^SHA1\(([^)]+)\)= ([0-9a-f]+)$/\1 \2/"
}

function hash_remote_files() {
  curl --netrc -sS https://${API_HOST}/packages/${REPO_KEY}/files | \
  python2.7 -c '
import json
import sys

for entry in json.load(sys.stdin):
  print("{} {}".format(entry["path"], entry["sha1"]))
'
}

files=($(comm -2 -3 <(hash_local_files | sort) <(hash_remote_files | sort) | cut -d' ' -f1))
if [[ -n "${FILTER}" ]]
then
  all_files="${files[@]}"
  files=()
  for file in ${all_files}
  do
    if echo ${file} | grep "${FILTER}"
    then
      files+=(${file})
    fi
  done
fi

if (( ${#files[@]} > 0 ))
then
  echo "The following files will be uploaded to version ${VERSION}:"
  echo "=="
  for f in ${files[@]}; do
    echo "  $f"
  done

  read -n 1 -p "Press any key to continue, or hit ctrl+c to abort..."

  for f in ${files[@]}; do
    echo -n -e "\n${f}:\n  "
    statuscode=$(curl \
      --netrc \
      --output /dev/stderr \
      --write-out "%{http_code}" \
      --upload-file $f \
      --progress-bar \
      "https://${API_HOST}/content/${REPO_KEY}/${VERSION}/${f}?override=1&publish=1")
  done
  echo "Finished."
else
  echo "Bintray is already up to date!"
fi


