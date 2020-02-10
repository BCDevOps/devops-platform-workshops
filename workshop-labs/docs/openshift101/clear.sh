#!/usr/bin/env bash
set -e
set -o pipefail

pushd . > /dev/null
SCRIPT_PATH="${BASH_SOURCE[0]}"
while([ -h "${SCRIPT_PATH}" ]); do cd `dirname "$SCRIPT_PATH"`; SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
cd `dirname ${SCRIPT_PATH}` > /dev/null; SCRIPT_PATH=`pwd`;
popd  > /dev/null
source "${SCRIPT_PATH}/_common.sh"

oc -n "${TOOLS_NS}" delete all,secret -l "app=rocketchat-${STUDENT_ID}"
oc -n "${DEV_NS}" delete all,secret -l "app=rocketchat-${STUDENT_ID}"
