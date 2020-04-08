#!/usr/bin/env bash
set -e
set -o pipefail

TOOLS_NAMESPACE='ocp101-tools'
DEV_NAMESPACE='ocp101-dev'
WORKBENCH_NAMESPACE="${TOOLS_NAMESPACE}"

if [ "$(tail -c 1 github-users.txt)" != "" ]; then echo "ERROR: File 'github-users.txt' must end with new line!"; exit 1; fi

: > github-users-valid.txt

while read githubUserId ; do
  validGithubUserId="$(curl -fsSL "https://api.github.com/users/${githubUserId}" | jq -rcM '.login')"
  githubUserId="$(tr '[:upper:]' '[:lower:]' <<< "${validGithubUserId}")"
  echo "${validGithubUserId}" >> github-users-valid.txt
  echo "githubUserId:${githubUserId}"
  echo "validGithubUserId:${validGithubUserId}"
done < github-users.txt
