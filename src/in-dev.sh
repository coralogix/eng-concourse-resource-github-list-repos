#!/usr/bin/env bash

set -euxo pipefail

auth_token=$(security find-generic-password -a "ari-becker" -s "Github Repos Personal Access Token" -w | tr -d " \n")

if [[ ! -d $1 ]]; then
  mkdir -p $1
fi

echo "{
  \"source\": {
    \"auth_token\"    : \"${auth_token}\",
    \"include_regex\" : \"^infra-\",
    \"org\"           : \"coralogix\"
  },
  \"version\": {
    \"hash\": \"d02bdee2cd80e6ec25be6c75a2ee51968c0daaebdb2c68f522c10b5bf26df38fcc31787e415f5914aeba10f73a3b8636b409da485b69b2eb61462c9699b82cf8\"
  }
}" | ./in $1

# \"team\"      : \"ops\",
# \"exclude\"   : [\"categorization\", \"webapi\"],
# \"exclude_regex\" : \"infra|sdk|eng-\"