#!/usr/bin/env bash
set -e
set -o pipefail

[ -z ${1+x} ] &&  echo 'Missing content folder path argument ($1). e.g: ../workshop-labs/docs/openshift101' && exit 1

[ ! -f .rc.env ] && echo ".rc.env filed not found!" && exit 1

source .rc.env

[ -z ${rc_url+x} ] &&  echo "Environment Variable 'rc_url' has not been set or it is empty" && exit 1
[ -z ${rc_user_id+x} ] &&  echo "Environment Variable 'rc_user_id' has not been set or it is empty" && exit 1
[ -z ${rc_user_token+x} ] &&  echo "Environment Variable 'rc_user_token' has not been set or it is empty" && exit 1
[ -z ${rc_room+x} ] &&  echo "Environment Variable 'rc_room' has not been set or it is empty" && exit 1

# Get Room ID
#room_id="$(curl -fsSL -H "X-Auth-Token: ${rc_user_token}" -H "X-User-Id: ${rc_user_id}" "${rc_url}/api/v1/rooms.info?roomName=${rc_room}" | jq -r '.room._id')"

# Create Discussion
#curl -fsSL -H "X-Auth-Token: ${rc_user_token}" -H "X-User-Id: ${rc_user_id}" -H "Content-Type: application/json" "${rc_url}/api/v1/rooms.createDiscussion" -d '{ "prid": "hhRHZBiPzuX27L3XL", "t_name": "Labs Progress"}'

find "$1" -type f -name '*.md' | sort | while read -r path; do
  name="$(basename "$path")"
  header="$(head -1 "${path}" | sed -e 's/^#[[:space:]]*//' -e 's/[[:space:]]*$//')"

#  if [ ! -z ${rc_room+x} ]; then
    curl -fsSL -H "X-Auth-Token: ${rc_user_token}" \
      -H "X-User-Id: ${rc_user_id}" \
      -H "Content-type:application/json" \
      "${rc_url}/api/v1/chat.postMessage" \
      -d '{ "roomId": "'"${rc_room}"'", "text": "Lab '"${name:0:2}"' - '"${header}"'" }' -o /dev/null
#  else
#    curl -fsSL -H "X-Auth-Token: ${rc_user_token}" \
#      -H "X-User-Id: ${rc_user_id}" \
#      -H "Content-type:application/json" \
#      "${rc_url}/api/v1/chat.postMessage" \
#      -d '{ "channel": "'"${rc_channel}"'", "text": "Lab '"${name:0:2}"' - '"${header}"'" }' -o /dev/null
#  fi
done;
