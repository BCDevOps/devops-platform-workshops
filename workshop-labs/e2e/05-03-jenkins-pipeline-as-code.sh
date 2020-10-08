#!/bin/bash

. ./utils.sh
.  ./constants.sh

prompt "loaded constants"

# has DIR and USERNAME
cat ./constants.sh


TEMP_GRAFANA_DIR=$DIR/.grafana
GRAFANA_NAME="$USERNAME-grafana"
PROMETHEUS_NAME="$USERNAME-prometheus"
LOKI_NAME=$USERNAME-loki

GRAFANA_DASHBOARD_PROVIDERS_TEMPLATE=$DIR/fixtures/grafana-dashboards.yml
GRAFANA_DATASOURCES_TEMPLATE=$DIR/fixtures/grafana-datasources.yml
GRAFANA_DASHBOARD_TEMPLATE=$DIR/fixtures/grafana-simple-dashboard.json
GRAFANA_DEPLOYMENT_TEMPLATE=$DIR/fixtures/grafana-template.yaml


function waitForObjectsToDelete {
  GRAFANA_RESOURCES=""
  LOKI_RESOURCES=""
  PROMETHEUS_RESOURCES=""
  until [ "$GRAFANA_RESOURCES" = "0" -a "$PROMETHEUS_RESOURCES" = "0" -a "$LOKI_RESOURCES" = "0" ]; do
    prompt "waiting for loki, prometheus, and grafana resources to be deleted using oc get all ..."
    GRAFANA_RESOURCES=$(oc get all,configmap,pvc -l app=$GRAFANA_NAME -n $DEV_NAMESPACE -o json | jq '.items | length')
    GRAFANA_RESOURCES=$(oc get all,configmap,pvc -l app=$LOKI_NAME -n $DEV_NAMESPACE -o json | jq '.items | length')
    GRAFANA_RESOURCES=$(oc get all,configmap,pvc -l app=$PROMETHEUS_NAME -n $DEV_NAMESPACE -o json | jq '.items | length')
    sleep 1
  done
}

function cleanupTest {
  prompt "Cleaning Up Test"
  prompt "Deleting created object in oc"
  oc delete all,configmap,secret,pvc -l app=$GRAFANA_NAME -n $DEV_NAMESPACE
  oc delete all,configmap,secret,pvc -l app=$LOKI_NAME -n $DEV_NAMESPACE
  oc delete all,configmap,secret,pvc -l app=$PROMETHEUS_NAME -n $DEV_NAMESPACE
  prompt "Waiting for deletion to complete"
  waitForObjectsToDelete
  prompt "Deletion complete"
}

title " Jenkins and Basic Pipeline Integration E2E  "

checkWhoAmI

checkDevAndToolsNamespaceAreSet

checkNamespaceValidity

oc project $DEV_NAMESPACE

cleanupTest

describe 1 "Deploy Grafana Using OpenShift Tools"

prompt "Reminder: This E2E test has dependencies for Loki and Prometheus. If you require these to be created you can run the helm e2e test"

sleep 5

prompt "a. Deploying grafana to dev namespace with command oc new-app grafana/grafana:6.2.0 --name $GRAFANA_NAME"

oc new-app grafana/grafana:6.2.0 --name $GRAFANA_NAME -n $DEV_NAMESPACE

prompt "b. Exploring the objects generated from the utility with oc get all -l app=$GRAFANA_NAME -o json"

ITEMS=$(oc get all -l app=$GRAFANA_NAME -o json -n $DEV_NAMESPACE | jq '.items | length')

# casting to num
ITEMS=$(($ITEMS - 0))

assert "that the previous call retrieved a list of items"

if [ $ITEMS -lt 1 ]; then
  prompt "No items could be found"
  exitNicely
fi

prompt "Items found"

prompt "c. Exposing the Grafana service with oc expose service $GRAFANA_NAME --name $GRAFANA_NAME -n $DEV_NAMESPACE"

ROUTE=$(oc expose service $GRAFANA_NAME --name $GRAFANA_NAME -n $DEV_NAMESPACE -o json | jq '.spec.host')

prompt "This part of the test requires going through the grafana gui at $ROUTE"
prompt "This script will not attempt to emulate user actions through a gui and instead will skip to editing the configmap in this lab"


describe 2 "Configure Grafana Without State (aka. configMaps)"

prompt "a. Creating configmaps through oc instead of using the gui with oc create and a fixtured files"

prompt "Previewing dashboard providers"
head -20 $GRAFANA_DASHBOARD_PROVIDERS_TEMPLATE

prompt "Previewing datasources"
head -20 $GRAFANA_DATASOURCES_TEMPLATE

prompt "Previewing sample dashboard"
head -20 $GRAFANA_DASHBOARD_TEMPLATE

GRAFANA_DASHBOARD_PROVIDERS_CONFIGMAP=$GRAFANA_NAME-dashboard-providers
GRAFANA_DASHBOARD_PROVIDERS_CONFIGMAP_MOUNTPATH=/etc/grafana/provisioning/dashboards

GRAFANA_DATASOURCES_CONFIGMAP=$GRAFANA_NAME-datasources
GRAFANA_DATASOURCES_CONFIGMAP_MOUNTPATH=/etc/grafana/provisioning/datasources

GRAFANA_DASHBOARDS_CONFIGMAP=$GRAFANA_NAME-dashboards
GRAFANA_DASHBOARDS_CONFIGMAP_MOUNTPATH=/var/lib/grafana/dashboards/

prompt "Running oc create configmap $GRAFANA_DASHBOARD_PROVIDERS_CONFIGMAP --from-file=dashboards.yml=$GRAFANA_DASHBOARD_PROVIDERS_TEMPLATE -n $DEV_NAMESPACE"

oc create configmap $GRAFANA_DASHBOARD_PROVIDERS_CONFIGMAP  --from-file=dashboards.yml=$GRAFANA_DASHBOARD_PROVIDERS_TEMPLATE -n $DEV_NAMESPACE

prompt "patching config map with the label app=$GRAFANA_NAME so it can be cleaned up later"

oc patch configmap $GRAFANA_DASHBOARD_PROVIDERS_CONFIGMAP -p "{\"metadata\": {\"labels\": {\"app\": \"$GRAFANA_NAME\"}}}" -n $DEV_NAMESPACE

prompt "created and patched the dashboard provider configmap"

prompt "Creating datasources configmap"
prompt "** the datasources template needs to have service names replaced, this is being done with sed **"

PROMETHEUS_TAG='$PROMETHEUS SERVICE NAME'
PROMETHEUS_SERVICE_NAME="$USERNAME-prometheus-test"

LOKI_TAG='$LOKI SERVICE NAME'
LOKI_SERVICE_NAME="$USERNAME-loki-headless"

prompt "** making temp dir at $TEMP_GRAFANA_DIR to hold the template configmap **"
mkdir $TEMP_GRAFANA_DIR

VALID_GRAFANA_DATASOURCES_TEMPLATE=$TEMP_GRAFANA_DIR/valid-datsources.yml
cat $GRAFANA_DATASOURCES_TEMPLATE | sed -e "s/$PROMETHEUS_TAG/$PROMETHEUS_SERVICE_NAME/" -e "s/$LOKI_TAG/$LOKI_SERVICE_NAME/" > $VALID_GRAFANA_DATASOURCES_TEMPLATE

prompt "Substitution complete now creating configmap and patching to add the app label"

oc create configmap $GRAFANA_DATASOURCES_CONFIGMAP  --from-file=datasources.yml=$VALID_GRAFANA_DATASOURCES_TEMPLATE -n $DEV_NAMESPACE
oc patch configmap $GRAFANA_DATASOURCES_CONFIGMAP -p "{\"metadata\": {\"labels\": {\"app\": \"$GRAFANA_NAME\"}}}" -n $DEV_NAMESPACE

prompt "created and patched the datasources configmap"

prompt "Creating and patching Dashboard Configmap"

oc create configmap $GRAFANA_DASHBOARDS_CONFIGMAP --from-file=simple_dashboard.json=$GRAFANA_DASHBOARD_TEMPLATE -n $DEV_NAMESPACE
oc patch configmap $GRAFANA_DASHBOARDS_CONFIGMAP -p "{\"metadata\": {\"labels\": {\"app\": \"$GRAFANA_NAME\"}}}" -n $DEV_NAMESPACE

prompt "created and patched the dashboards configmap"

prompt "b. Applying configmaps as volumes to the grafana deployment config"

prompt "Adding $GRAFANA_DASHBOARD_PROVIDERS_CONFIGMAP to deployment config at $GRAFANA_DASHBOARD_PROVIDERS_CONFIGMAP_MOUNTPATH using oc set"

oc set volume dc/$GRAFANA_NAME --add --type=configmap --configmap-name=$GRAFANA_DASHBOARD_PROVIDERS_CONFIGMAP --mount-path=$GRAFANA_DASHBOARD_PROVIDERS_CONFIGMAP_MOUNTPATH --default-mode=420 -n $DEV_NAMESPACE

prompt "Adding $GRAFANA_DATASOURCES_CONFIGMAP to deployment config at $GRAFANA_DATASOURCES_CONFIGMAP_MOUNTPATH using oc set"

oc set volume dc/$GRAFANA_NAME --add --type=configmap --configmap-name=$GRAFANA_DATASOURCES_CONFIGMAP --mount-path=$GRAFANA_DATASOURCES_CONFIGMAP_MOUNTPATH --default-mode=420 -n $DEV_NAMESPACE

prompt "Adding $GRAFANA_DASHBOARDS_CONFIGMAP to deployment config at $GRAFANA_DASHBOARDS_CONFIGMAP_MOUNTPATH using oc set"

oc set volume dc/$GRAFANA_NAME --add --type=configmap --configmap-name=$GRAFANA_DASHBOARDS_CONFIGMAP --mount-path=$GRAFANA_DASHBOARDS_CONFIGMAP_MOUNTPATH --default-mode=420 -n $DEV_NAMESPACE

prompt "Completed adding volumes to dc/$GRAFANA_NAME"

assert "There are 3 configmaps in dc/$GRAFANA_NAME"

CONFIG_MAPS_LENGTH=$(oc get dc/$GRAFANA_NAME -o json -n $DEV_NAMESPACE | jq '.spec.template.spec.volumes | length')

if [ "$CONFIG_MAPS_LENGTH" != "3" ]; then 
  prompt "3 Config maps were not found"
  exitNicely
fi

prompt "Assertion succesful"

prompt "c. Redeploying grafana"

oc rollout latest dc/$GRAFANA_NAME

describe 3 "Creating an OpenShift Deployment Artifact for Grafana"

prompt "a. Reviewing all artifacts associated with Grafana running oc get all -l app=$GRAFANA_NAME -n $DEV_NAMESPACE"

oc get all -l app=$GRAFANA_NAME -n $DEV_NAMESPACE

prompt "b. expanding to get configmaps"

oc get all,configmap -l app=$GRAFANA_NAME -n $DEV_NAMESPACE
GRAFANA_DEPLOYMENT=$TEMP_GRAFANA_DIR/graphana-template.json

prompt "c. exporting objects into a manifest $GRAFANA_DEPLOYMENT"

prompt "*** manfiest exported as json so that it may be manipulated with jq ***"
oc get all,configmap -l app=$GRAFANA_NAME --export -o json -n $DEV_NAMESPACE> $GRAFANA_DEPLOYMENT

prompt "d. Verifying that the file works by removing all objects and deploying from the manifest"

prompt "running oc delete"

oc delete -n $DEV_NAMESPACE all,configmap -l app=$GRAFANA_NAME

prompt "applying file"

oc apply -f $GRAFANA_DEPLOYMENT -n $DEV_NAMESPACE

prompt "e. removing replication controllers and pods from template"

VALID_GRAFANA_DEPLOYMENT=$TEMP_GRAFANA_DIR/valid-graphana-template.json
VALID_GRAFANA_DEPLOYMENT_ITEMS=$TEMP_GRAFANA_DIR/valid-graphana-items.json
cat $GRAFANA_DEPLOYMENT | jq '.items | map(select((.kind == "Pod") or (.kind == "ReplicationController") | not))' | sponge $VALID_GRAFANA_DEPLOYMENT_ITEMS

cat $GRAFANA_DEPLOYMENT | jq --argfile items $VALID_GRAFANA_DEPLOYMENT_ITEMS '.items = $items' | sponge $VALID_GRAFANA_DEPLOYMENT

prompt "f. reapplying template after deleting Pod and Replication Controller objects"

oc apply -f $VALID_GRAFANA_DEPLOYMENT -n $DEV_NAMESPACE

prompt "h. Removing specific meta data from template objects"

prompt "removing metadata.selfLink, metadata.creationTimestamp, metadata.uid, metadata.resourceVersion from buildconfig file \n\n"

jq "del(.items[].metadata.creationTimestamp)" $VALID_GRAFANA_DEPLOYMENT | sponge $VALID_GRAFANA_DEPLOYMENT
prompt "removed metadata.creationTimestamp \n\n"
jq "del(.items[].metadata.uid)" $VALID_GRAFANA_DEPLOYMENT | sponge $VALID_GRAFANA_DEPLOYMENT
prompt "removed metadata.uid \n\n"
jq "del(.items[].metadata.resourceVersion)" $VALID_GRAFANA_DEPLOYMENT | sponge $VALID_GRAFANA_DEPLOYMENT
prompt "removed metadata.resourceVersion \n\n"
jq "del(.items[].metadata.selfLink)" $VALID_GRAFANA_DEPLOYMENT | sponge $VALID_GRAFANA_DEPLOYMENT
prompt "removed metadata.selfLink \n\n"
jq "del(.items[].status)" $VALID_GRAFANA_DEPLOYMENT | sponge $VALID_GRAFANA_DEPLOYMENT
prompt "removed status \n\n"

prompt "i. deleting all objects and reapplying"


oc delete -n $DEV_NAMESPACE all,configmap -l app=$GRAFANA_NAME

oc apply -f $VALID_GRAFANA_DEPLOYMENT -n $DEV_NAMESPACE

sleep 2

assert "reapplying twice leaves all objects unchanged"
oc apply -f $VALID_GRAFANA_DEPLOYMENT -n $DEV_NAMESPACE
oc apply -f $VALID_GRAFANA_DEPLOYMENT -n $DEV_NAMESPACE

describe 4 "Creating a Template for Grafana"

prompt "using a fixture file for the template"

prompt "previewing fixure"

head -20 $GRAFANA_DEPLOYMENT_TEMPLATE

prompt "a. installing template in $DEV_NAMESPACE"

oc create -f $GRAFANA_DEPLOYMENT_TEMPLATE

prompt "b. deploying another version of grafana"

oc process grafana-template \
    -p GRAFANA_SERVICE_NAME=graphana-2 \
    -p LOKI_SERVICE_NAME=$LOKI_SERVICE_NAME \
    -p PROMETHEUS_SERVICE_NAME=$PROMETHEUS_SERVICE_NAME \
    -p ROUTE_SUBDOMAIN=pathfinder.gov.bc.ca \
    -p NAMESPACE=$DEV_NAMESPACE \
    | oc apply -f - -n $DEV_NAMESPACE

assert "Grafana was created from template"

ITEMS_LENGTH=$(oc get all,configmap -l app=graphana-2 -n $DEV_NAMESPACE | jq '.items | length')

if [ "$ITEMS_LENGTH" = "0" ];then 
  prompt "Grafana template was not successful"
  exitNicely
fi 

prompt "removing temp dir"

rm -rf $TEMP_GRAFANA_DIR

prompt " END OF TEST "