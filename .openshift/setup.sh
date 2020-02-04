#!/usr/bin/env bash
set -e
set -o pipefail

pushd . > /dev/null
SCRIPT_PATH="${BASH_SOURCE[0]}"
while([ -h "${SCRIPT_PATH}" ]); do cd `dirname "$SCRIPT_PATH"`; SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
cd `dirname ${SCRIPT_PATH}` > /dev/null; SCRIPT_PATH=`pwd`;
popd  > /dev/null

GIT_TOP_DIR="$(git rev-parse --show-toplevel)"

source "${SCRIPT_PATH}/_common.sh"
source "${SCRIPT_PATH}/.env"


if ! oc whoami >/dev/null ; then
  echo -e "Sorry. You are not logged in!\nPlease visit https://console.pathfinder.gov.bc.ca:8443/console/ and use the provided login command."
  exit 1
fi

oc_host="$(oc config current-context | cut -d'/' -f2)"
if [ ${oc_host} != "console-pathfinder-gov-bc-ca:8443" ]; then
  echo "You are not logged in the right cluster"
  #exit 1
fi
source "${SCRIPT_PATH}/setup-${1}.sh"
