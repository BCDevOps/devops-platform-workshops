#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TEMP_HELM_DIR=${DIR}/.helm_temp
USERNAME="e2e-tester"
PROMETHEUS_NAME="$USERNAME-prometheus"

. ./utils.sh

title "  Building Openshift Templates E2E  "
