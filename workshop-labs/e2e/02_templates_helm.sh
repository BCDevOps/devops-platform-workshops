#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TEMP_HELM_DIR=${DIR}/.helm_temp
USERNAME="e2e-tester"
PROMETHEUS_NAME="$USERNAME-prometheus"

function exitNicely {
  printf "\n\n Exiting :) \n\n"
  rm ${temp_bc_file}
  rm ${temp_dc_file}
  exit 1
}

function waitForObjectsToDelete {
  resources=""
  until [ "$resources" = "0" ]; do
    resources=$(oc get all,configmap,pvc -l component=$PROMETHEUS_NAME -n $DEV_NAMESPACE -o json | jq '.items | length')
    sleep 1
  done
}

printf "========================================\n"
printf "==  Templates Helm E2E  ==\n"
printf "========================================\n\n\n"


sleep 1

printf "*reminder* You need to be logged in to run this e2e test\n"

WHO_ARE_YOU=$(oc whoami)

printf "Logged in as $WHO_ARE_YOU \n\n"

printf "==Checking Dependencies==\n\n"


./tools_check.sh 

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

printf "Cleaning up temp directories \n\n"
rm -rf ${TEMP_HELM_DIR}

printf "Cleaning up previous tests with oc delete all,configmap,pvc -l component=test\n\n"

oc delete all,configmap,secret,pvc -l component=test -n ${DEV_NAMESPACE}
oc delete all,configmap,secret,pvc -l app=loki -n ${DEV_NAMESPACE}

waitForObjectsToDelete

printf "===1. Obtain Helm===\n\n"

printf "Init helm in client only mode \n\n"

helm init --client-only

printf "switching into dev"

oc project $DEV_NAMESPACE

printf "===2. Deploy Prometheus into Dev Namespace===\n\n"

printf "a. review list of charts with helm repo list\n\n"

helm repo list

printf "b. searching from prometheus\n\n"

helm search prometheus

printf "c. fetching the prometheus chart and verifying the tgz package is downloaded\n\n"

printf "** making a temp dir to run these actions ${TEMP_HELM_DIR}** \n\n"
mkdir $TEMP_HELM_DIR


helm fetch stable/prometheus -d $TEMP_HELM_DIR

PROMETHEUS=$(ls -lha $TEMP_HELM_DIR | grep prometheus)

if [ -z "$PROMETHEUS" ]; then
  printf "Unable to find prometheus, the chart may have no been fetched. Exiting \n"
  exitNicely
fi

printf "*** Prometheus found ***\n\n"

printf "d. Using the helm client to generate the prometheus server component using username ${USERNAME}\n\n"

PROMETHEUS_TAR="$TEMP_HELM_DIR/prometheus-9.1.2.tgz"
PROMETHEUS_TEMPLATE_YAML="$TEMP_HELM_DIR/$PROMETHEUS_NAME.yaml"
PROMETHEUS_TEMPLATE_JSON="$TEMP_HELM_DIR/$PROMETHEUS_NAME.json"

printf "Attempting to create a template with ${PROMETHEUS_TAR}\n"
helm template $PROMETHEUS_TAR \
  --name $PROMETHEUS_NAME \
  --set \
server.persistentVolume.size=1Gi,\
server.name=test,\
alertmanager.enabled=false,\
pushgateway.enabled=false,\
kubeStateMetrics.enabled=false,\
nodeExporter.enabled=false,\
serviceAccounts.server.create=false,\
rbac.create=false \
> $PROMETHEUS_TEMPLATE_YAML

printf "Template created in YAML\n\n"

head -20 $PROMETHEUS_TEMPLATE_YAML

printf "**Converting yaml template into json so its easier to query against during this e2e test**\n\n"

oc apply -f $PROMETHEUS_TEMPLATE_YAML -n $DEV_NAMESPACE --dry-run -o json > $PROMETHEUS_TEMPLATE_JSON

printf "e. Deploy Prometheus to $DEV_NAMESPACE using oc apply -f $PROMETHEUS_TEMPLATE_JSON -n $DEV_NAMESPACE\n\n"

oc apply -f $PROMETHEUS_TEMPLATE_JSON -n $DEV_NAMESPACE

printf "\n f. Asserting that the deployment fails as it is attempting to read cluster information\n\n"

RETRIES=1
MAX_RETRIES=10
FAILURE_FOUND=false

echo $REPLICA_FAILURE

printf "Checking status with oc get deployment/$PROMETHEUS_NAME-test -n $DEV_NAMESPACE -o json\n\n"

until [ "$RETRIES" = "$MAX_RETRIES" ]; do
  REPLICA_FAILURE=$(oc get deployment/$PROMETHEUS_NAME-test -n $DEV_NAMESPACE -o json \
  | jq '.status.conditions[] | select(.type=="ReplicaFailure")')
  if [ -z "$REPLICA_FAILURE" ]; then
    printf "Retrying Status Check in 2 seconds (retry $RETRIIES)\n"
    RETRIES=$(($RETRIES + 1))
    sleep 2
  else 
    FAILURE_FOUND=true;
    break;
  fi
done

if [ "$RETRIES" = "$MAX_RETRIES" -a "$FAILURE_FOUND" = false ]; then
  printf "Was unable to assert a failure happened\n\n"
  exitNicely
fi

printf "Prometheus correctly asserted to be failing\n\n"

printf "h. Adjusting Config Map\n\n"

printf "h.1 Removing cluster wide specifics from configmap\n\n"

VALID_PROMETHEUS_CONFIG=""

printf "** replacing namespace placeholder from valid config using sed\n"

VALID_PROMETHEUS_CONFIG=$(cat $DIR/fixtures/valid_prometheus.yml | sed -e "s/\$PROJECT NAME/${DEV_NAMESPACE}/")

printf "modify configmap\n"

CONFIG_MAP_FILE="$TEMP_HELM_DIR/configmap.json"

cat $PROMETHEUS_TEMPLATE_JSON | jq '.items[] | select(.kind=="ConfigMap")' | sponge $CONFIG_MAP_FILE

cat $CONFIG_MAP_FILE | jq --arg data "$VALID_PROMETHEUS_CONFIG" '.data += {"prometheus.yml": $data}'  | sponge $CONFIG_MAP_FILE

printf "config map modified to only query namespace $DEV_NAMESPACE\n\n"

printf "replacing bad configmap in $PROMETHEUS_TEMPLATE_JSON"
PROMETHEUS_TEMP_ITEMS=$TEMP_HELM_DIR/prometheus_temp.json
PROMETHEUS_VALID_DEPLOYMENT=$TEMP_HELM_DIR/prometheus_deployment.json

cat $PROMETHEUS_TEMPLATE_JSON | jq --argfile configmap $CONFIG_MAP_FILE '.items[] | select(.kind == "ConfigMap") = $configmap' | sponge $PROMETHEUS_TEMP_ITEMS

cat $PROMETHEUS_TEMPLATE_JSON | jq --argfile items $PROMETHEUS_TEMP_ITEMS '.items = $items' | sponge $PROMETHEUS_TEMPLATE_JSON

printf "\nConfigmap replaced\n\n"
rm $PROMETHEUS_TEMP_ITEMS

printf "h.2 Removing Security Context from Deployment\n\n"
cat $PROMETHEUS_TEMPLATE_JSON | jq '.items[] | select(.kind == "Deployment") | .spec.template.spec | del(.securityContext)' | sponge $PROMETHEUS_VALID_DEPLOYMENT

cat $PROMETHEUS_TEMPLATE_JSON | jq  --argfile containerTemplate $PROMETHEUS_VALID_DEPLOYMENT '.items[] | select(.kind == "Deployment") | .spec.template.spec = $containerTemplate' | sponge $PROMETHEUS_VALID_DEPLOYMENT

cat $PROMETHEUS_TEMPLATE_JSON | jq --argfile validDeploy $PROMETHEUS_VALID_DEPLOYMENT '.items[] | select(.kind == "Deployment") = $validDeploy' | sponge $PROMETHEUS_TEMP_ITEMS

cat $PROMETHEUS_TEMPLATE_JSON | jq --argfile items $PROMETHEUS_TEMP_ITEMS '.items = $items' | sponge $PROMETHEUS_TEMPLATE_JSON

printf "i. Applying template again using oc apply -f $PROMETHEUS_TEMPLATE_JSON -n $DEV_NAMESPACE\n\n"

oc apply -f $PROMETHEUS_TEMPLATE_JSON -n $DEV_NAMESPACE

printf "j. Adding default service account with view permission\n\n"

oc policy add-role-to-user view -z default -n $DEV_NAMESPACE

printf "k. Adding route to prometheus service\n\n"

oc get service -n $DEV_NAMESPACE

oc expose service $PROMETHEUS_NAME-test --name prometheus -l app=prometheus -l component=test -n $DEV_NAMESPACE

printf "===3. Deploy Another App with Helm===\n\n\n"
LOKI_NAME=$USERNAME-loki
LOKI_TEMPLATE_YAML=$TEMP_HELM_DIR/loki_template.yaml
LOKI_TEMPLATE_JSON=$TEMP_HELM_DIR/loki_template.json

printf "a. fetching and deploying loki \n\n"
helm repo add loki https://grafana.github.io/loki/charts
helm fetch loki/loki -d $TEMP_HELM_DIR
helm template $TEMP_HELM_DIR/loki-0.26.1.tgz --name=$LOKI_NAME \
--set rbac.create=false,rbac.pspEnabled=false,serviceAccount.create=false \
> $LOKI_TEMPLATE_YAML
oc apply -f $LOKI_TEMPLATE_YAML -n $DEV_NAMESPACE -o json > $LOKI_TEMPLATE_JSON

printf "\n b. Asserting that the deployment fails as it is attempting to read security context\n\n"

RETRIES=1
MAX_RETRIES=10
FAILURE_FOUND=false

echo $REPLICA_FAILURE

printf "Checking status with oc get statefulset/$LOKI_NAME -n $DEV_NAMESPACE -o json\n\n"
sleep 4
until [ "$RETRIES" = "$MAX_RETRIES" ]; do
  REPLICAS=$(oc get statefulset/$USERNAME-loki -n $DEV_NAMESPACE -o json \
  | jq '.status.replicas')
  if [ "$REPLICAS" != "0" ]; then
    printf "Retrying Status Check in 2 seconds (retry $RETRIIES)\n"
    RETRIES=$(($RETRIES + 1))
    sleep 2
  else 
    FAILURE_FOUND=true;
    break;
  fi
done

if [ "$RETRIES" = "$MAX_RETRIES" -a "$FAILURE_FOUND" = false ]; then
  printf "Was unable to assert a failure happened\n\n"
  exitNicely
fi

printf "Loki correctly asserted to be failing\n\n"

printf "Modifying Statefulset to remove sefcurity context and then redeploy"

LOKI_VALID_STATEFULSET=$TEMP_HELM_DIR/loki_statefulset.json
LOKI_TEMP_ITEMS=$TEMP_HELM_DIR/loki_temp.json

cat $LOKI_TEMPLATE_JSON | jq '.items[] | select(.kind == "StatefulSet") | .spec.template.spec | del(.securityContext)' | sponge $LOKI_VALID_STATEFULSET

cat $LOKI_TEMPLATE_JSON | jq  --argfile containerTemplate $LOKI_VALID_STATEFULSET '.items[] | select(.kind == "StatefulSet") | .spec.template.spec = $containerTemplate' | sponge $LOKI_VALID_STATEFULSET

cat $LOKI_TEMPLATE_JSON | jq --argfile validDeploy $LOKI_VALID_STATEFULSET '.items[] | select(.kind == "StatefulSet") = $validDeploy' | sponge $LOKI_TEMP_ITEMS

cat $LOKI_TEMPLATE_JSON | jq --argfile items $LOKI_TEMP_ITEMS '.items = $items' | sponge $LOKI_TEMPLATE_JSON

printf "Complete removing security context \n\n"

printf "Re applying loki template\n\n"

oc apply -f $LOKI_TEMPLATE_JSON -n $DEV_NAMESPACE

printf "Verifying theres 1 replica\n\n"
sleep 4
REPLICAS=$(oc get statefulset/$USERNAME-loki -n $DEV_NAMESPACE -o json \
  | jq '.status.replicas')

printf "Replicas of Loki: $REPLICAS\n\n"

if [ "$REPLICAS" = "0" ]; then
  printf "Replicas were zero\n"
  exitNicely
fi

printf "Test completed. \nDeleted temp files \n\n"

rm -rf $TEMP_HELM_DIR


