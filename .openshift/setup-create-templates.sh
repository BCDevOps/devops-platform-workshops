set -e
set -o pipefail
#set -o xtrace #same as set -x
#set -v

function create_workbench_build_template {
  TEMPLATE_PATH="${WORKBENCH_BUILD_TEMPLATE_PATH}"
  echo "Creating $(basename "${TEMPLATE_PATH}")"

  pushd "${GIT_TOP_DIR}" > /dev/null
  mkdir -p "$(dirname "${TEMPLATE_PATH}")"
  oc -n "${NS_WORKBENCH}" new-build . --context-dir=.openshift/images/workbench --strategy=docker -o json '--name=workbench' > "${TEMPLATE_PATH}"
  popd > /dev/null

  convert_list_to_template "${TEMPLATE_PATH}" "workbench"

  # Ading Fedora ImageStream
  _jq 'del(.objects[] | select(.kind == "ImageStream" and .name == "fedora-minimal"))' "${TEMPLATE_PATH}"
  _jq '.objects += [{"apiVersion":"image.openshift.io/v1","kind":"ImageStream","metadata":{"annotations":null,"creationTimestamp":null,"generation":1,"labels":{"app":"workbench","template":"workbench"},"name":"fedora-minimal"},"spec":{"lookupPolicy":{"local":false},"tags":[{"annotations":{"openshift.io/imported-from":"registry.fedoraproject.org/fedora-minimal:30"},"from":{"kind":"DockerImage","name":"registry.fedoraproject.org/fedora-minimal:30"},"generation":1,"importPolicy":{},"name":"30","referencePolicy":{"type":"Local"}}]},"status":{"dockerImageRepository":""}}]' "${TEMPLATE_PATH}"


  #echo "Squash Layers"
  _jq '(.objects[] | select(.kind == "BuildConfig" and .spec.strategy.dockerStrategy !=null)).spec.strategy.dockerStrategy.imageOptimizationPolicy |= "SkipLayers"' "${TEMPLATE_PATH}"

  #echo "Removing triggers"
  _jq 'del(.objects[] | select(.kind == "BuildConfig") | .spec.triggers[] | select(.type == "GitHub" or .type == "Generic" or .type == "ImageChange" or .type == "ConfigChange"))' "${TEMPLATE_PATH}"

  #echo "Increasing CPU/Memory for the build"
  _jq '(.objects[] | select(.kind == "BuildConfig") | .spec.resources) |= {"requests" : {"cpu": "0", "memory": "0"}, "limits": {"cpu": "0", "memory": "0"}}' "${TEMPLATE_PATH}"

}

function create_workbench_deployment_template {
  TEMPLATE_PATH="${WORKBENCH_DEPLOYMENT_TEMPLATE_PATH}"
  echo "Creating $(basename "${TEMPLATE_PATH}")"

  pushd "${GIT_TOP_DIR}" > /dev/null
  mkdir -p "$(dirname "${TEMPLATE_PATH}")"
  set -x
  oc -n "${NS_WORKBENCH}" new-app --allow-missing-images=true --allow-missing-imagestream-tags=true --image-stream="${NS_WORKBENCH}/workbench:latest" "--name=ocp101-workbench" --dry-run -o json  > "${TEMPLATE_PATH}"
  set +x
  popd > /dev/null

  convert_list_to_template "${TEMPLATE_PATH}" "workbench"
  _jq 'del(.objects[] | select(.kind == "ImageStreamTag"))' "${TEMPLATE_PATH}"

  # 48 hours = 172800 seconds
  #_jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.activeDeadlineSeconds = 172800' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.automountServiceAccountToken = true' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.serviceAccountName = "student"' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.containers[0].image = "docker-registry.default.svc:5000/'"${NS_WORKBENCH}"'/workbench:latest"' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.containers[0].name = "app"' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig").spec.template.spec.containers[] | select(.name == "app")).resources = {"requests": {"cpu":"200m", "memory":"128Mi"}, "limits": {"memory": "256Mi", "cpu":"500m"}}' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.containers[].imagePullPolicy |= "Always"' "${TEMPLATE_PATH}"


  _jq '.parameters = [{"name": "NAME", "required": true}, {"name":"SUFFIX", "required": false}, {"name":"IMAGE_NAMESPACE", "required": true}, {"name":"IMAGE_NAME", "required": true}]' "${TEMPLATE_PATH}"

  _jq '(.objects[] | .metadata).name = "${NAME}${SUFFIX}"' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "Service" or .kind == "DeploymentConfig")).spec.selector = {"statefulset": "${NAME}${SUFFIX}"}' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.metadata.labels = {"statefulset": "${NAME}${SUFFIX}"}' "${TEMPLATE_PATH}"


  # Convert DeploymentConfig to Statefulset
  _jq 'del(.objects[] | select(.kind == "DeploymentConfig") | .spec.triggers)' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.updateStrategy = {"type":"RollingUpdate"}' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig")).kind = "StatefulSet"' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "StatefulSet")).apiVersion = "apps/v1"' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "StatefulSet")).spec.selector = {"matchLabels":{"statefulset":"${NAME}${SUFFIX}"}}' "${TEMPLATE_PATH}"
}

function create_labs_build_template {
  TEMPLATE_PATH="${LABS_BUILD_TEMPLATE_PATH}"
  echo "Creating $(basename "${TEMPLATE_PATH}")"

  NS_TOOLS="${NS_WORKBENCH}"
  pushd "${GIT_TOP_DIR}" > /dev/null
  mkdir -p "$(dirname "${TEMPLATE_PATH}")"
  _ocb new-build . --context-dir=workshop-labs --strategy=docker -o json '--name=ocp101-labs' > "${TEMPLATE_PATH}"
  popd > /dev/null

  convert_list_to_template "${TEMPLATE_PATH}" "ocp101-labs"
  _jq 'del(.objects[] | select(.kind == "ImageStreamTag"))' "${TEMPLATE_PATH}"
  _jq 'del(.objects[] | select(.kind == "ImageStream" and .metadata.name == "ocp101-labs")) | .objects |= [{"kind":"ImageStream","apiVersion":"image.openshift.io/v1","metadata":{"name":"ocp101-labs","creationTimestamp":null,"labels":{},"annotations":{}},"spec":{"lookupPolicy":{"local":false}},"status":{"dockerImageRepository":""}}] + .' "${TEMPLATE_PATH}"
  _jq 'del(.objects[] | select(.kind == "ImageStream" and .metadata.name == "gitbook-base")) | .objects |= [{"kind":"ImageStream","apiVersion":"image.openshift.io/v1","metadata":{"name":"gitbook-base","creationTimestamp":null,"labels":{},"annotations":{}},"spec":{"lookupPolicy":{"local":false},"tags":[{"name":"3.2.3","annotations":{"openshift.io/imported-from":"arctiqteam/gitbook-base:3.2.3"},"from":{"kind":"DockerImage","name":"arctiqteam/gitbook-base:3.2.3"},"generation":null,"importPolicy":{},"referencePolicy":{"type":"Local"}}]},"status":{"dockerImageRepository":""}}] + .' "${TEMPLATE_PATH}"

  _jq '(.objects[] | select(.kind == "BuildConfig" and .spec.strategy.dockerStrategy !=null)).spec.strategy.dockerStrategy.imageOptimizationPolicy |= "SkipLayers"' "${TEMPLATE_PATH}"

  #echo "Removing triggers"
  _jq 'del(.objects[] | select(.kind == "BuildConfig") | .spec.triggers[] | select(.type == "GitHub" or .type == "Generic" or .type == "ImageChange" or .type == "ConfigChange"))' "${TEMPLATE_PATH}"

  #echo "Increasing CPU/Memory for the build"
  _jq '(.objects[] | select(.kind == "BuildConfig") | .spec.resources) |= {"requests" : {"cpu": "1", "memory": "1Gi"}, "limits": {"cpu": "2", "memory": "2Gi"}}' "${TEMPLATE_PATH}"
}

function create_labs_main_deployment_template {
  TEMPLATE_PATH="${LABS_MAIN_DEPLOYMENT_TEMPLATE_PATH}"
  echo "Creating $(basename "${TEMPLATE_PATH}")"

  pushd "${GIT_TOP_DIR}" > /dev/null
  mkdir -p "$(dirname "${TEMPLATE_PATH}")"
  oc -n "${NS_WORKBENCH}" new-app --image-stream="${NS_WORKBENCH}/ocp101-labs:latest" "--name=ocp101-labs" --dry-run -o json  > "${TEMPLATE_PATH}"
  popd > /dev/null

  convert_list_to_template "${TEMPLATE_PATH}" "ocp101-labs"
  _jq 'del(.objects[] | select(.kind == "ImageStreamTag"))' "${TEMPLATE_PATH}"

  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.containers[0].image |= " "' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.containers[0].name = "app" | (.objects[] | select(.kind == "DeploymentConfig") | .spec.triggers[] | select( .type == "ImageChange")).imageChangeParams.containerNames = ["app"]' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig").spec.template.spec.containers[] | select(.name == "app")).resources = {"requests": {"cpu":"10m", "memory":"40Mi"}, "limits": {"memory": "60Mi", "cpu":"50m"}}' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.containers[].imagePullPolicy |= "Always"' "${TEMPLATE_PATH}"


  #echo "Adding Readiness Probe"
  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.containers[0].readinessProbe = {"failureThreshold":3,"httpGet":{"path":"/","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}' "${TEMPLATE_PATH}"

  #echo "Exposing Service as Route"
  _jq '.objects += [{"kind":"Route","apiVersion":"route.openshift.io/v1","metadata":{"name":"ocp101-labs","creationTimestamp":null,"labels":{"app":"ocp101-labs"}},"spec":{"host":"","to":{"kind":"Service","name":"ocp101-labs","weight":100},"port":{"targetPort":"4000-tcp"},"tls":{"insecureEdgeTerminationPolicy": "Redirect", "termination": "edge"}},"status":{"ingress":null}}]' "${TEMPLATE_PATH}"

  _jq '.parameters = [{"name": "NAME", "required": true}, {"name": "HOST", "required": true}, {"name":"SUFFIX", "required": false}, {"name":"IMAGE_NAMESPACE", "required": true}, {"name":"IMAGE_NAME", "required": true}]' "${TEMPLATE_PATH}"

  _jq '(.objects[] | .metadata).name = "${NAME}${SUFFIX}"' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "Service" or .kind == "DeploymentConfig")).spec.selector = {"deploymentconfig": "${NAME}${SUFFIX}"}' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.metadata.labels = {"deploymentconfig": "${NAME}${SUFFIX}"}' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "DeploymentConfig").spec.triggers[] | select(.type == "ImageChange")).imageChangeParams.from += {"namespace": "${IMAGE_NAMESPACE}", "name": "${IMAGE_NAME}"}' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "Route")).spec.host = "${HOST}"' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "Route")).spec.to.name = "${NAME}${SUFFIX}"' "${TEMPLATE_PATH}"
}

function create_labs_student_deployment_template {
  TEMPLATE_PATH="${LABS_STUDENT_DEPLOYMENT_TEMPLATE_PATH}"
  echo "Creating $(basename "${TEMPLATE_PATH}")"

  cp "${LABS_MAIN_DEPLOYMENT_TEMPLATE_PATH}" "${TEMPLATE_PATH}"

  _jq '.parameters += [{"name": "STUDENT_ID", "required": true},{"name": "NAMESPACE_TOOLS", "required": true},{"name": "NAMESPACE_DEV", "required": true}]' "${TEMPLATE_PATH}"

  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.containers[0].command = ["/opt/app-root/bin/student.sh","caddy2", "file-server","-root","/opt/app-root/book","--listen",":4000"]' "${TEMPLATE_PATH}"

  _jq '(.objects[] | select(.kind == "Route")).spec.path = "/student/${STUDENT_ID}"' "${TEMPLATE_PATH}"

  _jq '(.objects[] | select(.kind == "DeploymentConfig")).spec.template.spec.containers[0].env += [{"name":"HOME", "value":"/home/nobody"},{"name":"STUDENT", "value":"${STUDENT_ID}"},{"name":"NAMESPACE_TOOLS", "value":"${NAMESPACE_TOOLS}"},{"name":"NAMESPACE_DEV", "value":"${NAMESPACE_DEV}"}] ' "${TEMPLATE_PATH}"
}

function create_student_role_template {
  TEMPLATE_PATH="${TEMPLATES_DIR}/role-student.json"
  echo "Creating $(basename "${TEMPLATE_PATH}")"
  
  echo '{"kind": "Template","apiVersion": "v1", "metadata": {"name": "student-role"},"objects":[{"kind":"Role","apiVersion":"rbac.authorization.k8s.io/v1","metadata":{"name":"student","creationTimestamp":null},"rules":[]}]}' > "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "Role" and .metadata.name == "student")).rules += [{"verbs":["get"],"apiGroups":[""],"resources":["pods"]}]' "${TEMPLATE_PATH}"
  _jq '(.objects[] | select(.kind == "Role" and .metadata.name == "student")).rules += [{"verbs":["create"],"apiGroups":[""],"resources":["pods/exec"]}]' "${TEMPLATE_PATH}"
}

create_workbench_build_template
create_workbench_deployment_template
create_labs_build_template
create_labs_main_deployment_template
create_labs_student_deployment_template
create_student_role_template