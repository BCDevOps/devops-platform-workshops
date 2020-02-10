#!/usr/bin/env bash
set -e
set -o pipefail

pushd . > /dev/null
SCRIPT_PATH="${BASH_SOURCE[0]}"
while([ -h "${SCRIPT_PATH}" ]); do cd `dirname "$SCRIPT_PATH"`; SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
cd `dirname ${SCRIPT_PATH}` > /dev/null; SCRIPT_PATH=`pwd`;
popd  > /dev/null
#echo "SCRIPT_PATH:${SCRIPT_PATH}"
source "${SCRIPT_PATH}/_common.sh"
LAB_FILE="$(find "${SCRIPT_PATH}" -type f -name "${1}_*.md" | head -1)"
LAB_NUM="${1}"
LAB_NAME="$(basename "${LAB_FILE}" '.md')"
LAB_TITLE="$(head -1 "${LAB_FILE}" | sed -e 's/^#[[:space:]]*//' -e 's/[[:space:]]*$//')"

echo "Fixing Lab ${LAB_NUM} - ${LAB_TITLE}"
source "${SCRIPT_PATH}/${LAB_NAME}.fix.sh"