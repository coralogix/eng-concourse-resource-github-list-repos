#!/usr/bin/env bash

function query_github_list_repos() {
    input_json=$1

    # parse out the input params
    ## required
    auth_token=$(       echo "${input_json}" | jq '.source.auth_token'              -r)
    org=$(              echo "${input_json}" | jq '.source.org'                     -r)

    ## optional
    team=$(             echo "${input_json}" | jq '.source.team? // empty'           -r)
    exclude_regex=$(    echo "${input_json}" | jq '.source.exclude_regex? // empty'  -r)
    exclude=$(          echo "${input_json}" | jq '.source.exclude[]? // empty'      -r)

    # validate
    ## auth_token must be defined
    if [[ "${auth_token}" == "null" ]]; then
        echo "[ERROR] auth_token was not defined! Please define auth_token so that this resource can authenticate with the GitHub API." 1>&2
        exit 1
    fi
    ## org must be defined
    if [[ "${org}" == "null" ]]; then
        echo "[ERROR] org was not defined! Please define org so that this resource will know which organization's repositories you are trying to fetch." 1>&2
        exit 1
    fi

    # pre-processing for query
    ## exclusion regex
    final_exclude_regex=
    if [[ ! -z "${exclude_regex}" ]]; then
        final_exclude_regex=${exclude_regex}
        if [[ ! -z "${exclude}" ]]; then
            final_exclude_regex=${final_exclude_regex}'|'
        fi
    fi
    if [[ ! -z "${exclude}" ]]; then
        exclude=$(echo ${exclude} | paste -s - | sed -e 's/[[:space:]+]/|/g')
        final_exclude_regex=${final_exclude_regex}${exclude}
    fi

    if [[ -z "${final_exclude_regex}" ]]; then
        # never exclude anything since nothing can come after the end
        final_exclude_regex='$a'
    fi

    ## team inserts
    team_gql_wrapper_begin=""
    team_gql_wrapper_end=""
    team_jq_parser=""
    if [[ ! -z ${team} ]]; then
        team_gql_wrapper_begin="team(slug: \\\"${team}\\\") {"
        team_gql_wrapper_end="}"
        team_jq_parser=".team"
    fi

    # iterate through repos
    has_next_page="true"
    after_cursor=
    response=

    while [[ ${has_next_page} == "true" ]]; do
      repo_gql="query {
            organization(login: \\\"${org}\\\") {
                ${team_gql_wrapper_begin}
                repositories(first: 100${after_cursor}) {
                    totalCount
                    edges {
                        node {
                            name
                        }
                    }
                    pageInfo {
                        endCursor
                        hasNextPage
                    }
                }
                ${team_gql_wrapper_end}
            }
        }"

      ### Don't ask why this is necessary. Just don't. Or ask Mark Zuckerberg.
      repo_gql="$(echo ${repo_gql})"
      repo_response=$(curl -sL -H "Authorization: bearer ${auth_token}" -X POST -d "{\"query\":\"${repo_gql}\"}" https://api.github.com/graphql)

      # Parse response
      # save num repos
      # echo ${repo_response} | jq -r ".data.organization${team_jq_parser}.repositories.totalCount" > /tmp/repositoryTotalCount.txt

      after_cursor=$(echo ${repo_response} | jq -r ".data.organization${team_jq_parser}.repositories.pageInfo.endCursor")
      after_cursor=", after: \\\"${after_cursor}\\\""
      has_next_page=$(echo ${repo_response} | jq -r ".data.organization${team_jq_parser}.repositories.pageInfo.hasNextPage")
      response+=$(echo ${repo_response} | jq -r ".data.organization${team_jq_parser}.repositories.edges[].node.name" | grep -Ev "${final_exclude_regex}")$'\n'
    done

    echo ${response}
}

function version_hash() {
    sort | paste -sd ',' - | shasum --algorithm 512 | tr -d ' -'
}