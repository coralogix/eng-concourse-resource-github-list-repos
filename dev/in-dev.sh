#!/usr/bin/env bash

set -euxo pipefail

auth_token=$(security find-generic-password -a "ari-becker" -s "Github Repos Personal Access Token" -w | tr -d " \n")

echo "{
  \"source\": {
    \"auth_token\": \"${auth_token}\",
    \"org\"       : \"coralogix\"
  },
  \"version\": {
    \"hash\": \"09fc854f15daf805a74cafd0d94d292913de78269960401fabc1697f6ce7850cd17c1ed5c89f2145d9a7ea218bf56230d6759f471bde464a39a1e71bbc2debac\"
  }
}" | ../src/in $1

# \"team\"      : \"ops\",
# \"exclude\"   : [\"categorization\", \"webapi\"],
# \"exclude_regex\" : \"infra|sdk|eng-\"