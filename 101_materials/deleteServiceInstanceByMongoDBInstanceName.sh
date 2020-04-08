#!/usr/bin/env bash
set -e
set -o pipefail

NAMESPACE="$1"
MONGODB_SERVICE_NAME="$2"

function findServiceInstance {
  while read serviceInstance secretName clusterServiceClassRef clusterServiceClassExternalName ; do
    if [ "${clusterServiceClassExternalName}" == "mongodb-ephemeral" ]; then
      encodedParameters=$(oc -n "${NAMESPACE}" get "secret/${secretName}" -o custom-columns=P:.data.parameters --no-headers)
      decodedParameters=$(base64 -D <<< "${encodedParameters}")
      databaseServiceName=$(jq -r '.DATABASE_SERVICE_NAME' <<< "${decodedParameters}")
      if [ "${databaseServiceName}" == "${1}" ]; then
        echo "${serviceInstance}"
      fi
    fi
  done < <(oc -n "${NAMESPACE}" get ServiceInstance -o 'custom-columns=N:.metadata.name,S:.spec.parametersFrom[].secretKeyRef.name,CSCR:.spec.clusterServiceClassRef.name,CSCN:.spec.clusterServiceClassExternalName' --no-headers)
}

findServiceInstance "${MONGODB_SERVICE_NAME}" | xargs -t -I {} oc -n "${NAMESPACE}" delete 'ServiceInstance/{}'

