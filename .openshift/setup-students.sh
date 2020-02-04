set -e
echo "Setting up students environment"
source .rc.env

rocketchat_announcement=1
dry_run=0

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
        -d '{ "roomId": "'"${rc_workbenches_room_id}"'", "text": "Hi @'"${2}"' !\nLab content:\n-> `https://ocp101-labs-ocp101a-workbench.pathfinder.gov.bc.ca/student/'"${3}"'`\nYour remote workbench:\n->`oc -n '"${NS_WORKBENCH}"' rsh workbench-'"${3}"'-0`" }'
    fi
}

# Empty the file!
: > github-users-valid.txt
while IFS=, read githubUserId rocketChatUserId aliasId __other; do
  #remove whitespaces/line breaks
  githubUserId="$(tr -d '[:space:]' <<< "${githubUserId}")"
  rocketChatUserId="$(tr -d '[:space:]' <<< "${rocketChatUserId}")"
  aliasId="$(tr -d '[:space:]' <<< "${aliasId}")"
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
done < <(curl -fsSL "${GOOGLE_DOCS_CSV_URL}" | tail -n +2 | head -n 2)

# wait for all backgorund jobs to finish
wait
