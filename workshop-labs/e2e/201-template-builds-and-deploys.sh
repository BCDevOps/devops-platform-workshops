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

printf "========================================\n"
printf "==  Testing Build and Deploy Lab E2E  ==\n"
printf "========================================\n\n\n"

sleep 2

printf "*reminder* You need to be logged in to run this e2e test\n"

WHO_ARE_YOU=$(oc whoami)

printf "Logged in as $WHO_ARE_YOU \n\n"

printf "==Checking Dependencies==\n\n"

printf "Checking tput \n\n"
BLUE=""
if [ -z $(which tput) ];
then
  printf "tput cannot be found. it is used for color formatting."
  BLUE=$(tput setaf 4)
fi
printf "Checking oc \n\n"

if [ -z $(which oc) ];
then
  printf "oc cannot be found"
  exitNicely
fi

printf "Checking jq \n\n"

if [ -z $(which jq) ];
then
  printf "jq cannot be found"
  exitNicely
fi


printf "Checking sponge \n\n"

if [ -z $(which sponge) ];
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

printf "Cleaning up previous tests with oc delete all -l build=${APP_NAME}\n\n"

oc delete all,imagestream -l build=${APP_NAME}

printf "===Creating A New Build and Extracting the Infrastructure Code===\n\n"

printf "Triggering a dry-runned build \n\n"
oc -n ${TOOLS_NAMESPACE} new-build https://github.com/bcdevops/devops-platform-workshops#${REF} --context-dir=demo-express-server --name=${APP_NAME} --dry-run -o json > ${temp_bc_file}

printf "Captured output into a temp file $temp_bc_file \n\n"

printf "Build Config Contents... (first 10 lines)\n\n"
head -10 $temp_bc_file

printf "JSON output used for test to utilize jq\n\n"

printf "===Clearing up the Garbage===\n\n"
sleep 1
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

sleep 1

printf "Completed cleaning of garbage \n\n"
head -20 ${temp_bc_file}

printf "===Improving the BuildConfig===\n\n"

printf "1. Adding resources to BuildConfig\n\n"

RESOURCE_CONFIG="$DIR/fixtures/resources.json"
temp_bc_with_resources=$(mktemp)
cat $temp_bc_file | jq --argfile resources $RESOURCE_CONFIG '.items[1] | .spec += {resources: $resources}'  | sponge $temp_bc_with_resources
cat $temp_bc_file | jq --argfile bc $temp_bc_with_resources '.items[1] = $bc' | sponge $temp_bc_file
rm $temp_bc_with_resources

printf "2. Added resources to bc, now applying changes \n\n"

sleep 1

printf "a. Deleting resources with oc delete all -l build=$APP_NAME  -n $TOOLS_NAMESPACE \n\n"
oc delete all -l build=$APP_NAME -n $TOOLS_NAMESPACE
sleep 5
printf "b. Applying resources with oc apply -f $temp_bc_file -n $TOOLS_NAMESPACE \n\n"
oc apply -f $temp_bc_file
sleep 5
printf "c. Restarting build with oc start-build bc/$APP_NAME -n $TOOLS_NAMESPACE \n\n"

printf "${BLUE}Note ${BLUE}for ${BLUE}testing ${BLUE}the ${BLUE}--wait ${BLUE}flag is being used \n"
# oc start-build bc/$APP_NAME --wait


printf "3. Adding labels to BuildConfig and Imagestream \n\n"

LABELS_CONFIG="$DIR/fixtures/labels.json"
printf "a. applying labels app, team, and project\n\n"
cat $temp_bc_file | jq --argfile labels $LABELS_CONFIG '.items[].metadata += {labels: $labels}' | sponge $temp_bc_file

printf "b. running oc apply \n\n"
oc apply -f $temp_bc_file

APP_LABEL=$(cat $LABELS_CONFIG | jq '.app')
printf "c. checking if you can query objects by app label using oc get all -l app=$APP_NAME \n\n"

printf "note test is using JSON output to get item length with jq \n\n"

ITEMS_LENGTH=$(oc get all -l app=$APP_NAME -o json | jq '.items | length')

printf "Asserting oc get all -l app=$APP_NAME .length should equal 2"

if [ ITEMS_LENGTH = "2"];
then
  echo "length didn't equal 2. Exiting"
  exitNicely
else
  printf "length equaled 2. Huzzah! \n\n"
fi

sleep 2

printf "4.  Change the output image tag to __NOT BE LATEST__\n\n"

IMAGE_TAG_CONFIG="$DIR/fixtures/bc-output-image.json"
printf "Modifying build config to have an output image tag of \n"

cat $IMAGE_TAG_CONFIG

printf "\n"

temp_bc_with_image_output=$(mktemp)
cat $temp_bc_file | jq --argfile output $IMAGE_TAG_CONFIG '.items[1] | .spec += {output: $output}'  | sponge $temp_bc_with_image_output
cat $temp_bc_file | jq --argfile bc $temp_bc_with_image_output '.items[1] = $bc' | sponge $temp_bc_file

printf "Image Output Configurations applied. Checking with jq '.items[1].spec.output' $temp_bc_file \n\n"

jq '.items[1].spec.output' $temp_bc_file

sleep 2

printf "Test completed. \n deleted temp files \n\n"

rm ${temp_bc_file}
rm ${temp_dc_file}