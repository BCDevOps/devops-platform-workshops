set -e
echo "Setting up students environment"
source .rc.env

rocketchat_announcement=0
dry_run=1

function rc_curl {
  curl -D "rocketchat-headers.txt" -H "X-Auth-Token: ${rc_user_token}" -H "X-User-Id: ${rc_user_id}" -H "Content-type:application/json" "$@"
  limit_ramaining="$(grep 'X-RateLimit-Remaining' rocketchat-headers.txt | cut -d':' -f2 | tr -d '[:space:]')"
  if [ "${limit_ramaining}" == "1" ]; then
    limit_reset_in_ms="$(grep 'X-RateLimit-Reset' rocketchat-headers.txt | cut -d':' -f2 | tr -d '[:space:]')"
    limit_reset_in_s="$(date -r $((limit_reset_in_ms/1000)) "+%s")"
    now_in_s="$(date "+%s")"
    sleep_in_s=$((limit_reset_in_s - now_in_s))
    #printf "limit_ramaining=${limit_ramaining}, limit_reset_in_s='${limit_reset_in_s}', limit_reset_in_ms='${limit_reset_in_ms}', now_in_s=${now_in_s} sleep_in_s\n" >&2
    printf "\033[48;5;95;38;5;214mAPI rate limit reached! Sleeping for ${sleep_in_s}s ...\033[0m\n" >/dev/stderr
    sleep "${sleep_in_s}"
  fi
}

# $1 GitHub
# $2 RochetChat
# $3 alias
function deploy_student {
    oc -n "${NS_WORKBENCH}" policy add-role-to-user "--role-namespace=${NS_WORKBENCH}" student "${1}" || true
    ( STUDENT_ID="$3" "${SCRIPT_PATH}/setup.sh" "deploy-student-docs")
    ( STUDENT_ID="$3" "${SCRIPT_PATH}/setup.sh" "deploy-student-workbench" )
    if [ "${rocketchat_announcement}" == "1" ]; then
      rc_curl -fsSL "${rc_url}/api/v1/chat.postMessage" \
        -d '{ "roomId": "'"${rc_workbenches_room_id}"'", "text": "Hi @'"${2}"' !\nLab content:\n-> `https://ocp101-labs-'"${NS_WORKBENCH}"'.pathfinder.gov.bc.ca/student/'"${3}"'`\n1) Visit https://console.pathfinder.gov.bc.ca:8443/console/command-line and copy your `oc login` command line with token.\n2) Open a terminal (e.g.: bash or windows command prompt) and paste the login command.\n3)Access your workbench by using:\n -> `oc -n '"${NS_WORKBENCH}"' rsh workbench-'"${3}"'-0`" }' &>/dev/null
    fi
}


curl -fsSL "${GOOGLE_DOCS_CSV_URL}" > students.csv

if [ "$(tail -c 1 students.csv | od -A n -t x1 | tr -d '[:space:]')" != "0a" ]; then
  echo "WARN: File 'students.csv' did not end with LF. One is being appended!"
  printf "\n" >> students.csv
fi

# Empty the file!
: > github-users-valid.txt
while IFS=, read studentNum githubUserId rocketChatUserId aliasId __other; do
  #remove whitespaces/line breaks
  githubUserId="$(tr -d '[:space:]' <<< "${githubUserId}")"
  rocketChatUserId="$(tr -d '[:space:]' <<< "${rocketChatUserId}")"
  #BUG: make alias all lower case
  aliasId="$(tr -d '[:space:]' <<< "${aliasId}")"
  aliasId="$(tr '[:upper:]' '[:lower:]' <<< "${aliasId}")"
  #echo "Processing githubUserId='${githubUserId}' rocketChatUserId='${rocketChatUserId}', alias='${aliasId}'"
  #continue
  echo "Verifying github:${githubUserId}"
  validGithubUserId="$(curl -fsSL -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/users/${githubUserId}" 2>/dev/null| jq -rcM '.login' || printf 'null')"
  lowerGithubUserId="$(tr '[:upper:]' '[:lower:]' <<< "${validGithubUserId}")"

  if [ "${validGithubUserId}" == "null" ]; then
    printf "\e[0;33mWARNING!GitHub account '${githubUserId}' was not found! skipping it!'\033[0m\n"
    continue
  fi

  [ "${rocketChatUserId}" == "" ] && rocketChatUserId="${validGithubUserId}"
  echo "Verifying RocketChat:${rocketChatUserId}"

  validRocketChatUsername="$(rc_curl -sSL -G -d "username=${rocketChatUserId}" "${rc_url}/api/v1/users.info" 2> /dev/null | jq -rcM '.user.username')"

  [ "${aliasId}" == "" ] && aliasId="${lowerGithubUserId}"

  echo "${validGithubUserId}" >> github-users-valid.txt
  #echo "Setting up user github(valid):${validGithubUserId} github(lower):${lowerGithubUserId} rocketchat:${rocketChatUserId} alias:${aliasId}"
  if [ "${githubUserId}" != "${validGithubUserId}" ]; then
    printf "\033[48;5;95;38;5;214mWARNING! GitHub account '${githubUserId}' should have been provided as '${validGithubUserId}'\033[0m\n"
  fi

  if [ "${validRocketChatUsername}" == "null" ]; then
    printf "\e[0;33mWARNING! User provided RocketChat username '${rocketChatUserId}' was not found! skipping!\033[0m\n"
    continue
  fi

  if [ "${dry_run}" != "1" ]; then
    #Process and apply templates in parallel/background
    deploy_student "${validGithubUserId}" "${validRocketChatUsername}" "${aliasId}" &
  fi
done < <(tail -n +2 < students.csv)

# wait for all backgorund jobs to finish
wait
