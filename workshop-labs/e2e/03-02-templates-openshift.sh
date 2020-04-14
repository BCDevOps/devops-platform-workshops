#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
temp_bc_file="${DIR}/bc.e2e.json"
temp_dc_file="${DIR}/dc.e2e.json"

touch ${temp_bc_file}
touch ${temp_dc_file}
. ./utils.sh

function waitForObjectsToDelete {
  resources=""
  until [ "$resources" = "0" ]; do
    resources=$(oc get all -l build=$APP_NAME -n $TOOLS_NAMESPACE -o json | jq '.items | length')
    sleep 1
  done
}

REF=""
APP_NAME="joke-api-e2e"
APP_NAME_IMAGE_SUFFIX="e2e"
clear

title " Testing Openshift Temlpates E2E  "

sleep 1

checkWhoAmI

prompt "==Checking Dependencies==\n\n"

./tools_check.sh

if [ -z ${BRANCH+x} ]; then REF="master"; else REF=$BRANCH; fi

checkDevAndToolsNamespaceAreSet

checkNamespaceValidity


prompt "1. Exploring Templates"
prompt "a. switching to dev namespace with oc project $DEV_NAMESPACE"

oc project $DEV_NAMESPACE

prompt "b. list templates in namespace"

oc get templates

prompt "**if the prior e2e test for grafana was run there should be a grafana template here\n this is not being asserted so that there is not a dependancy between e2e tests***"


prompt "c. list templates in openshift namespace"

oc get templates -n openshift

prompt "d. picking a template and describe it"

oc describe template jenkins -o openshift -n openshift

