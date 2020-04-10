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

title " Testing Build and Deploy Lab E2E  "

sleep 1

checkWhoAmI

prompt "==Checking Dependencies==\n\n"

./tools_check.sh

if [ -z ${BRANCH+x} ]; then REF="master"; else REF=$BRANCH; fi

checkDevAndToolsNamespaceAreSet

checkNamespaceValidity

prompt "Cleaning up previous tests with oc delete all -l build=${APP_NAME}\n\n"

oc delete all,imagestream -l build=${APP_NAME} -n $TOOLS_NAMESPACE

waitForObjectsToDelete

prompt "===Creating A New Build and Extracting the Infrastructure Code===\n\n"

prompt "Triggering a dry-runned build \n\n"
oc -n ${TOOLS_NAMESPACE} new-build https://github.com/bcdevops/devops-platform-workshops#${REF} --context-dir=demo-express-server --name=${APP_NAME} --dry-run -o json > ${temp_bc_file}

prompt "Captured output into a temp file $temp_bc_file \n\n"

prompt "Build Config Contents... (first 10 lines)\n\n"
head -10 $temp_bc_file

prompt "JSON output used for test to utilize jq\n\n"

prompt "===Clearing up the Garbage===\n\n"
sleep 1
prompt "removing metadata.selfLink, metadata.creationTimestamp, metadata.uid, metadata.resourceVersion from buildconfig file \n\n"

jq "del(.items[].metadata.creationTimestamp)" $temp_bc_file | sponge $temp_bc_file
prompt "removed metadata.creationTimestamp \n\n"
jq "del(.items[].metadata.uid)" $temp_bc_file | sponge $temp_bc_file
prompt "removed metadata.uid \n\n"
jq "del(.items[].metadata.resourceVersion)" $temp_bc_file | sponge $temp_bc_file
prompt "removed metadata.resourceVersion \n\n"
jq "del(.items[].metadata.selfLink)" $temp_bc_file | sponge $temp_bc_file
prompt "removed metadata.selfLink \n\n"
jq "del(.items[].status)" $temp_bc_file | sponge $temp_bc_file
prompt "removed status \n\n"

sleep 1

prompt "Completed cleaning of garbage \n\n"
head -20 ${temp_bc_file}

prompt "===Improving the BuildConfig===\n\n"

prompt "1. Adding resources to BuildConfig\n\n"

RESOURCE_CONFIG="$DIR/fixtures/resources.json"
temp_bc_with_resources=$(mktemp)
cat $temp_bc_file | jq --argfile resources $RESOURCE_CONFIG '.items[1] | .spec += {resources: $resources}'  | sponge $temp_bc_with_resources
cat $temp_bc_file | jq --argfile bc $temp_bc_with_resources '.items[1] = $bc' | sponge $temp_bc_file
rm $temp_bc_with_resources

prompt "2. Added resources to bc, now applying changes \n\n"

sleep 1

prompt "a. Deleting resources with oc delete all -l build=$APP_NAME  -n $TOOLS_NAMESPACE \n\n"
oc delete all -l build=$APP_NAME -n $TOOLS_NAMESPACE

waitForObjectsToDelete

prompt "b. Applying resources with oc apply -f $temp_bc_file -n $TOOLS_NAMESPACE \n\n"
oc apply -f $temp_bc_file

# prompt "c. Restarting build with oc start-build bc/$APP_NAME -n $TOOLS_NAMESPACE \n\n"

# prompt "${BLUE}Note ${BLUE}for ${BLUE}testing ${BLUE}the ${BLUE}--wait ${BLUE}flag is being used \n"
# oc start-build bc/$APP_NAME --wait


prompt "3. Adding labels to BuildConfig and Imagestream \n\n"

LABELS_CONFIG="$DIR/fixtures/labels.json"
prompt "a. applying labels app, team, and project\n\n"
cat $temp_bc_file | jq --argfile labels $LABELS_CONFIG '.items[].metadata += {labels: $labels}' | sponge $temp_bc_file

prompt "b. running oc apply \n\n"
oc apply -f $temp_bc_file

APP_LABEL=$(cat $LABELS_CONFIG | jq '.app')
prompt "c. checking if you can query objects by app label using oc get all -l app=$APP_NAME \n\n"

prompt "note test is using JSON output to get item length with jq \n\n"

ITEMS_LENGTH=$(oc get all -l app=$APP_NAME -o json | jq '.items | length')

prompt "Asserting oc get all -l app=$APP_NAME .length should equal 2"

if [ ITEMS_LENGTH = "2" ];
then
  echo "length didn't equal 2. Exiting"
  exitNicely
else
  prompt "length equaled 2. Huzzah! \n\n"
fi

## just so std out can be read
sleep 1

prompt "4.  Change the output image tag to __NOT BE LATEST__\n\n"

IMAGE_TAG_CONFIG="$DIR/fixtures/bc-output-image.json"
prompt "Modifying build config to have an output image tag of \n"

cat $IMAGE_TAG_CONFIG

prompt "\n"

temp_bc_with_image_output=$(mktemp)
cat $temp_bc_file | jq --argfile output $IMAGE_TAG_CONFIG '.items[1] | .spec += {output: $output}'  | sponge $temp_bc_with_image_output
cat $temp_bc_file | jq --argfile bc $temp_bc_with_image_output '.items[1] = $bc' | sponge $temp_bc_file

prompt "Image Output Configurations applied. Checking with jq '.items[1].spec.output' $temp_bc_file \n\n"

jq '.items[1].spec.output' $temp_bc_file

## so std out cnan be read
sleep 1

prompt "Test completed. \n deleted temp files \n\n"

rm ${temp_bc_file}
rm ${temp_dc_file}