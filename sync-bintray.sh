#!/usr/bin/env bash

API_HOST=api.bintray.com
BASE_URL=https://${API_HOST}/content/pantsbuild/bin/pants-support-binaries
VERSION=0.0.1

URL=${BASE_URL}/${VERSION}

FINALIZED=

function publish {
  curl \
    --fail \
    --netrc \
    --data "$1" \
    ${URL}/publish &> /dev/null
}

function finalize {
  echo "Publishing uploaded artifacts..."
  publish
}

function discard {
  if [[ -z "${FINALIZED}" ]]
  then
    echo -e "\nDiscarding uploaded artifacts..."
    publish '{"discard": true}'
  fi
}

function check_netrc {
  [[ -f ~/.netrc && -n "$(grep -E "^\s*machine\s+${API_HOST}\s*$" ~/.netrc)" ]]
}

if ! check_netrc
then
  echo "In order to publish bintray binaries you need an account"
  echo "with membership in the pantsbuild org [1]."
  echo
  echo "This account will need to be added to a ~/.netrc entry as follows:"
  echo 
  echo "machine ${API_HOST}"
  echo "  login <bintray username>"
  echo "  password <bintray api key [2]>"
  echo
  echo "[1] https://bintray.com/pantsbuild"
  echo "[2] https://bintray.com/docs/interacting/interacting_apikeys.html"
  exit 1
fi

trap "discard" EXIT

files=($(find build-support -type f))
count=${#files[@]}
for i in $(seq 1 ${count})
do
  file=${files[$((i-1))]}
  echo "[${i}/${count}] Uploading ${file}"
  (
    curl \
      --fail \
      --netrc \
      --upload-file ${file} \
      -o /dev/null \
      --progress-bar \
      -# \
      ${URL}/${file}
  ) || ( discard && exit 1 )
  echo
done

finalize && FINALIZED=true
