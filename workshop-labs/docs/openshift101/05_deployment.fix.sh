#!/usr/bin/env bash

image_pull_access=$(oc -n "${TOOLS_NS}" get RoleBinding -o json | jq --arg devNamespace "${DEV_NS}" '.items[] | select (.roleRef.name == "system:image-puller") | .subjects[] | select(.kind == "ServiceAccount" and .namespace == $devNamespace and .name == "default") | true')
if [ "${image_pull_access}" != 'true' ] ; then
  echo "Grating 'system:image-puller' privilege to 'system:serviceaccount:${DEV_NS}:default' on namespace ${TOOLS_NS}"
  oc -n ${TOOLS_NS} policy add-role-to-user 'system:image-puller' "system:serviceaccount:${DEV_NS}:default"
fi

image_tag=$(oc -n "${TOOLS_NS}" get "ImageStreamTag/rocketchat-${STUDENT_ID}:dev" --ignore-not-found=true -o 'custom-columns=N:.metadata.name' --no-headers)
if [ "${image_tag}" != "rocketchat-${STUDENT_ID}:dev" ] ; then
  echo "Creating 'dev' image tag"
  oc -n ${TOOLS_NS} tag "rocketchat-${STUDENT_ID}:latest" "rocketchat-${STUDENT_ID}:dev"
fi

oc -n ${DEV_NS} new-app --image-stream="${TOOLS_NS}/rocketchat-${STUDENT_ID}:dev" "--name=rocketchat-${STUDENT_ID}" --dry-run -o json  > "${LAB_NUM}-deployment.json"
echo "Converting List to Template"
convert_list_to_template "${LAB_NUM}-deployment.json" "rocketchat-${STUDENT_ID}"

# Deleting unecessary ImageStreamTag
_jq 'del(.objects[] | select(.kind == "ImageStreamTag"))' "${LAB_NUM}-deployment.json"

oc -n "${DEV_NS}" new-app '--template=mongodb-ephemeral' -p "DATABASE_SERVICE_NAME=mongodb-${STUDENT_ID}" -p "MONGODB_DATABASE=rocketchat" -p "MONGODB_USER=dbuser" -p "MONGODB_PASSWORD=dbpass" -p "MONGODB_VERSION=2.6" --dry-run -o json > "${LAB_NUM}-deployment-mongodb.json"
convert_list_to_template "${LAB_NUM}-deployment-mongodb.json" "rocketchat-${STUDENT_ID}"
#_jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.containers[].command = ["false"]' "${LAB_NUM}-deployment-mongodb.json"
_jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.strategy.recreateParams.timeoutSeconds = 300' "${LAB_NUM}-deployment-mongodb.json"

echo "Setting resource constraints"
_jq '(.objects[] | select(.kind == "DeploymentConfig").spec.template.spec.containers[]).resources = {"requests": {"cpu":"100m", "memory":"256Mi"}, "limits": {"memory": "512Mi", "cpu":"1000m"}}' "${LAB_NUM}-deployment-mongodb.json"

echo "Connecting RocketChat to MongoDB"
_jq --arg mongodbInstanceName "mongodb-${STUDENT_ID}" '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.containers[0].env = [{"name":"MONGO_USER","valueFrom":{"secretKeyRef":{"key":"database-user","name":$mongodbInstanceName}}},{"name":"MONGO_PASS","valueFrom":{"secretKeyRef":{"key":"database-password","name":$mongodbInstanceName}}},{"name":"MONGO_NAME","valueFrom":{"secretKeyRef":{"key":"database-name","name":$mongodbInstanceName}}},{"name":"MONGO_URL","value":("mongodb://$(MONGO_USER):$(MONGO_PASS)@"+$mongodbInstanceName+":27017/$(MONGO_NAME)")}]' "${LAB_NUM}-deployment.json"

echo "Exposing RocketChat Service as Route"
_jq --arg name "rocketchat-${STUDENT_ID}" '.objects += [{"kind":"Route","apiVersion":"route.openshift.io/v1","metadata":{"name":$name,"creationTimestamp":null,"labels":{"app":$name}},"spec":{"host":"","to":{"kind":"Service","name":$name,"weight":100},"port":{"targetPort":"3000-tcp"}},"status":{"ingress":null}}]' "${LAB_NUM}-deployment.json"

echo "Adding Readiness Probe"
_jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.containers[0].readinessProbe = {"failureThreshold":3,"httpGet":{"path":"/","port":3000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}' "${LAB_NUM}-deployment.json"

echo "Setting resource constraints"
_jq '(.objects[] | select(.kind == "DeploymentConfig").spec.template.spec.containers[]).resources = {"requests": {"cpu":"100m", "memory":"256Mi"}, "limits": {"memory": "1Gi", "cpu":"1000m"}}' "${LAB_NUM}-deployment.json"

oc -n "${DEV_NS}" get dc,svc,route -l "app=rocketchat-${STUDENT_ID}" --export -o json > "${LAB_NUM}-current.json"
oc -n "${DEV_NS}" create -f "${LAB_NUM}-deployment.json" --dry-run -o json > "${LAB_NUM}-proposed.json"

convert_list_to_template "${LAB_NUM}-current.json" "rocketchat-${STUDENT_ID}"
_jq --arg mongodbInstanceName "mongodb-${STUDENT_ID}" 'del(.objects[] | select( .metadata.name == $mongodbInstanceName))' "${LAB_NUM}-current.json"
jd "${LAB_NUM}-current.json" "${LAB_NUM}-proposed.json" > "${LAB_NUM}-diff.txt"

exit 1

echo "Scaling down existing RocketChat deployment"
oc -n "${DEV_NS}" scale "dc/rocketchat-${STUDENT_ID}" --replicas=0 || true
wait_for_replicas "${DEV_NS}" "dc/rocketchat-${STUDENT_ID}"

echo "Scaling down existing MongoDB deployment"
oc -n "${DEV_NS}" scale "dc/mongodb-${STUDENT_ID}" --replicas=0 || true
wait_for_replicas "${DEV_NS}" "dc/mongodb-${STUDENT_ID}"

echo "Applying MongoDB Deployment Template"
oc -n "${DEV_NS}" process -f "${LAB_NUM}-deployment-mongodb.json" -l "app=rocketchat-${STUDENT_ID}" | oc -n "${DEV_NS}" apply -f - --overwrite=true

echo "Waiting for MongoDB to come up"
wait_for_deployment "${DEV_NS}" "dc/mongodb-${STUDENT_ID}"
wait_for_replicas "${DEV_NS}" "dc/mongodb-${STUDENT_ID}"
echo "MongoDB is ready!"

echo "Applying RocketChat Deployment Template"
oc -n "${DEV_NS}" process -f "${LAB_NUM}-deployment.json" -l "app=rocketchat-${STUDENT_ID}" | oc -n "${DEV_NS}" apply -f - --overwrite=true

echo "Waiting for RocketChat to come up"
wait_for_deployment "${DEV_NS}" "dc/rocketchat-${STUDENT_ID}"
wait_for_replicas "${DEV_NS}" "dc/rocketchat-${STUDENT_ID}"

printf "RocketChat is ready!\nOpen your internet browser and go to \nhttp://$(oc -n "${DEV_NS}" get route/rocketchat-cvarjao -o custom-columns=H:.spec.host --no-headers)\n"

echo oc -n "${DEV_NS}" delete all,secret -l "app=rocketchat-${STUDENT_ID}"