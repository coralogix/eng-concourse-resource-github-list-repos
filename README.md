# GitHub List Repositories Resource

Lists the repositories that belong to a GitHub organization or team, but does not clone them.

This resource was implemented to trigger the reconfiguration and deployment of a Concourse CI pipeline which has jobs per repository (and therefore does not need to clone any of the repositories in order to build the pipeline). 

Internally uses the GitHub v4 API (GraphQL). 

## Source Configuration
* `access_token` : _Required_ (`string`). A GitHub API access token. This access token must have `repo` scope, and if the resource queries the repositories belonging to a team, it must also have `read:org` scope for the organization to which the team belongs.
* `org` : _Required_ (`string`). The organization whose repositories should be listed.
* `team` : _Optional_ (`string`). The team whose repositories should be listed. 
* `exclude_regex` : _Optional_ (`string`). A regular expression of repositories which should not be included in the final list.
* `exclude` : _Optional_ (`array[string]`). A list of repositories which should not be included in the final list. This list is appended to the `exclude_regex` to build a final exclusionary rule, and both `exclude` and `exclude_regex` may be specified.

### Example

Resource configuration

```yaml
resources:
- name: repo-list
  type: github-list-repos
  source:
    access-token: 1234567890abcdef
    org: myorg
    team: myteam
    exclude_regex: "internal-helper|utility"
    exclude:
    - irrelevant
    - legacy-service
```

## Behavior
 
### `check` : Check for a change in the repository list
The GitHub API is queried for a list of all of the repositories belonging to the `org` or the `team`. This list is sorted and hashed, so that subsequent calls will result in the same hash if no repositories have been added or deleted. This hash is returned as the version.

### `in` : Fetch a list of repositories
The GitHub API is queried for a list of all of the repositories belonging to the `org` or the `team`. This list is output to a file called `repository-list.<ext>` where `<ext>` is defined by the `output_format`.

#### Params
* `output_format` : _Optional_ (`string`). Specifies which format the list should be in. The options are `txt` (newline separated text file output to `repository-list.txt`) and `json` (a JSON array output to `repository-list.json`). `txt` is the default.

## `out` : Not supported