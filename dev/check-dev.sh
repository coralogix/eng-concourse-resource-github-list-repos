#!/usr/bin/env bash

set -euxo pipefail

auth_token=$(security find-generic-password -a "ari-becker" -s "Github Repos Personal Access Token" -w | tr -d " \n")

echo "{
  \"source\": {
    \"auth_token\": \"${auth_token}\",
    \"org\"       : \"coralogix\"
  }
}" | ../src/check

# \"team\"      : \"ops\",
# \"exclude\"   : [\"categorization\", \"webapi\"],
# \"exclude_regex\" : \"infra|sdk|eng-\"