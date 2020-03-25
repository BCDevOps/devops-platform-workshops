#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
temp_bc_file="${DIR}/bc.e2e.json"
temp_dc_file="${DIR}/dc.e2e.json"

touch ${temp_bc_file}
touch ${temp_dc_file}
function exitNicely {
  printf "\n\n Exiting :) \n\n"
  rm ${temp_bc_file}
  rm ${temp_dc_file}
  exit 1
}
REF=""
APP_NAME="joke-api-e2e"
APP_NAME_IMAGE_SUFFIX="e2e"
clear
printf "Testing Build and Deploy Lab E2E \n\n"

printf "You need to be logged in to run this e2e test\n"


WHO_ARE_YOU=$(oc whoami)

printf "Logged in as $WHO_ARE_YOU \n\n"

printf "==Checking Dependencies=="
printf "Checking oc \n\n"

if [ -z $(which oc)];
then
  printf "oc cannot be found"
  exitNicely
fi

printf "Checking jq \n\n"

if [ -z $(which jq)];
then
  printf "jq cannot be found"
  exitNicely
fi


printf "Checking sponge \n\n"

if [ -z $(which sponge)];
then
  printf "sponge cannot be found"
  exitNicely
fi

if [ -z ${BRANCH+x} ]; then REF="master"; else REF=$BRANCH; fi

printf "Checking DEV_NAMESPACE and TOOLS_NAMESPACE variables \n\n"

if [ -z ${DEV_NAMESPACE+x} ]; 
  then 
    echo "DEV_NAMESPACE not set. Exiting"
    exitNicely
  else printf "DEV_NAMESPACE set to ${DEV_NAMESPACE} \n\n" 
fi

if [ -z ${TOOLS_NAMESPACE+x} ]; 
  then 
    echo "TOOLS_NAMESPACE not set. Exiting"
    exitNicely
  else printf "TOOLS_NAMESPACE set to ${TOOLS_NAMESPACE} \n\n" 
fi

printf "Checking the namespaces are valid \n\n"

NAMESPACES=$(oc projects)

if [ -z $(echo "$NAMESPACES" | grep -w "${DEV_NAMESPACE}") ]
then
  echo "DEV_NAMESPACE doesn't exist. Exiting"
  exitNicely
else printf "DEV_NAMESPACE exists \n\n" 
fi


if [ -z $(echo "$NAMESPACES" | grep -w "${TOOLS_NAMESPACE}") ]
then
  echo "TOOLS_NAMESPACE doesn't exist. Exiting"
  exitNicely
else printf "TOOLS_NAMESPACE exists \n\n" 
fi

printf "===Creating A New Build and Extracting the Infrastructure Code===\n\n"

printf "Triggering a dry-runned build \n\n"
oc -n ${TOOLS_NAMESPACE} new-build https://github.com/bcdevops/devops-platform-workshops#${REF} --context-dir=demo-express-server --name=${APP_NAME} --dry-run -o json > ${temp_bc_file}

printf "Captured output into a temp file $temp_bc_file \n\n"

printf "Build Config Contents... (first 10 lines)\n\n"
head -10 $temp_bc_file

printf "JSON output used for test to utilize jq\n\n"

printf "===Clearing up the Garbage===\n\n"

printf "removing metadata.selfLink, metadata.creationTimestamp, metadata.uid, metadata.resourceVersion from buildconfig file \n\n"

jq "del(.items[].metadata.creationTimestamp)" $temp_bc_file | sponge $temp_bc_file
printf "removed metadata.creationTimestamp \n\n"
jq "del(.items[].metadata.uid)" $temp_bc_file | sponge $temp_bc_file
printf "removed metadata.uid \n\n"
jq "del(.items[].metadata.resourceVersion)" $temp_bc_file | sponge $temp_bc_file
printf "removed metadata.resourceVersion \n\n"
jq "del(.items[].metadata.selfLink)" $temp_bc_file | sponge $temp_bc_file
printf "removed metadata.selfLink \n\n"
jq "del(.items[].status)" $temp_bc_file | sponge $temp_bc_file
printf "removed status \n\n"


printf "Completed cleaning of garbage \n\n"
head -20 ${temp_bc_file}

printf "===Improving the BuildConfig===\n\n"

printf "Adding resources to BuildConfig\n\n"
RESOURCE_CONFIG=$(cat $DIR/fixtures/resource.json)
cat $temp_bc_file | jq --arg resources $RESOURCE_CONFIG '.items[1] | .spec + {resources: "bar"}' 
# rm ${temp_bc_file}
# rm ${temp_bc_file}