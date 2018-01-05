#!/usr/bin/env bash

ROOT="$(git rev-parse --show-toplevel)"

cd "${ROOT}/build-support"

if ! aws s3 sync --acl public-read . s3://binaries.pantsbuild.org
then
  echo
  echo "In order to run $0 you must 1st install AWS command line tools."
  echo "See: http://docs.aws.amazon.com/cli/latest/userguide/installing.html"
  echo
  echo "You'll also need to configure credentials for your IAM user. If you're using MFA,"
  echo "see: https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/"
  echo
  exit 1
fi

