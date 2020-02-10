function _jq {
  arg_file="${@: -1}"
  tmp_input_file="$(dirname $arg_file)/_$(basename $arg_file)"
  cp $arg_file "${tmp_input_file}"
  jq "${@:1:$#-1}" "${tmp_input_file}" > "$arg_file"
  rm "${tmp_input_file}"
}

# $1 Path to file with List of objects
# $2 Name o fthe template
function convert_list_to_template {
  _jq --arg name "$2" '.kind = "Template" | .objects = .items | del(.items) | .apiVersion = "template.openshift.io/v1" | .metadata.resourceVersion = "" | .metadata.selfLink = "" | del(.metadata.namespace)  | .metadata.name = $name | .labels = {"template": $name}' "$1"

  #echo "Removing superfluous labels and annotations"
  _jq 'del(.objects[] | .metadata.labels.build)' "$1"
  _jq 'del(.objects[] | .metadata.namespace)' "$1"
  _jq 'del(.objects[] | .metadata.resourceVersion)' "$1"
  _jq 'del(.objects[] | .metadata.selfLink)' "$1"
  _jq 'del(.objects[] | .metadata.uid)' "$1"
  _jq 'del(.objects[] | .metadata.generation)' "$1"
  _jq 'del(.objects[] | select(.kind == "DeploymentConfig") | .status)' "$1"
  _jq 'del(.objects[] | .metadata.annotations["openshift.io/generated-by"])' "$1"
  _jq 'del(.objects[] | .metadata.annotations["kubectl.kubernetes.io/last-applied-configuration"])' "$1"
  _jq '(.objects[] | .metadata).creationTimestamp = null' "$1"
  _jq '(.objects[] | select(.metadata.annotations == null)).metadata.annotations = {}' "$1"
  
  _jq '(.objects[] | select(.kind == "DeploymentConfig") | .spec.template.spec.containers[]).image = " "' "$1"
  _jq 'del(.objects[] | select(.kind == "DeploymentConfig") | .spec.template.spec.containers[].terminationMessagePath)' "$1"
  _jq 'del(.objects[] | select(.kind == "DeploymentConfig") | .spec.template.spec.containers[].terminationMessagePolicy)' "$1"
  _jq 'del(.objects[] | select(.kind == "DeploymentConfig") | .spec.triggers[] | select(.type == "ImageChange") | .imageChangeParams | .lastTriggeredImage)' "$1"
  _jq '(.objects[] | select(.kind == "DeploymentConfig" and .spec.template.spec.dnsPolicy == null)).spec.template.spec.dnsPolicy = "ClusterFirst"' "$1"
  _jq '(.objects[] | select(.kind == "DeploymentConfig" and .spec.template.spec.restartPolicy == null)).spec.template.spec.restartPolicy = "Always"' "$1"
  _jq '(.objects[] | select(.kind == "DeploymentConfig" and .spec.template.spec.schedulerName == null)).spec.template.spec.schedulerName = "default-scheduler"' "$1"
  _jq '(.objects[] | select(.kind == "DeploymentConfig" and .spec.template.spec.securityContext == null)).spec.template.spec.securityContext = {}' "$1"
  _jq '(.objects[] | select(.kind == "DeploymentConfig" and .spec.template.spec.terminationGracePeriodSeconds == null)).spec.template.spec.terminationGracePeriodSeconds = 30' "$1"
  _jq '(.objects[] | select(.kind == "DeploymentConfig") | .spec.template.spec.containers[] | select(.imagePullPolicy == null)).imagePullPolicy = "IfNotPresent"' "$1"

  _jq 'del(.objects[] | select(.kind == "Service") | .spec.clusterIP)' "$1"
  _jq '(.objects[] | select(.kind == "Service" and .spec.sessionAffinity == null)).spec.sessionAffinity="None"' "$1"
  _jq '(.objects[] | select(.kind == "Service" and .spec.type == null)).spec.type="ClusterIP"' "$1"

  _jq '(.objects[] | select(.kind == "Route") | .spec).host = ""' "$1"
  _jq '(.objects[] | select(.kind == "Route" and .spec.wildcardPolicy == null)).spec.wildcardPolicy = "None"' "$1"
  _jq 'del(.objects[] | select(.kind == "Route") | .status // {} | .ingress)' "$1"
}

# $1 namespace
# $2 Object/Resource
function wait_for_deployment {
  max_retries=3
  attempt=0
  sleep 3
  status="$(oc -n "$1" rollout status "$2" &>/dev/null; echo $?)"
  while [ "${status}" != "0"  ] && [ $attempt -lt $max_retries ]; do
    let "attempt+=1"
    echo "Triggering deployment for ${1}/${2}"
    oc -n "$1" rollout latest "$2" &>/dev/null
    status="$(oc -n "$1" rollout status "$2" &>/dev/null; echo $?)"
  done
  if [ "${status}" != "0"  ]; then
    echo "Failed deploying $2 after ${attempt} attempts :("
    return 1
  fi
}

function wait_for_replicas {
  max_retries=600
  attempt=0
  sleep 3
  successful=0

  while [ $attempt -lt $max_retries ]; do
    let "attempt+=1"
    #echo oc -n "$1" get pod -l "deploymentconfig=$(cut -d'/' -f2 <<< "$2")" -o name
    pods="$(oc -n "$1" get pod -l "deploymentconfig=$(cut -d'/' -f2 <<< "$2")" -o name | wc -l | tr -d ' ')"
    status="$(oc -n "$1" get "$2" -o json | jq '.status | del(.details) | del(.conditions)' )"
    replicas=$(jq '.replicas' <<< "${status}")
    unavailableReplicas=$(jq '.unavailableReplicas // 0' <<< "${status}")
    readyReplicas=$(jq '.readyReplicas // 0' <<< "${status}")
    if [ "${pods}" == "${replicas}" ] && [ "${readyReplicas}" == "${replicas}" ] && [ "${unavailableReplicas}" == "0" ]; then
      return 0
    fi
  done
  echo "Number of replicas didn't come up/down in time"
  echo "replicas:${replicas} pods:${pods} ready:${readyReplicas} unavailable:${unavailableReplicas} attempt:${attempt}"
  exit 1
}
# $1 namespace
# $2 Object/Resource
function assert_min_replicas {
  readyReplicas="$(oc -n "$1" get "$2" -o custom-columns=R:.status.readyReplicas --no-headers)"
  if [ "${readyReplicas}" == "<none>" ]; then
    echo "That is awkward ... there is no replicas running. Let me get 1 started for you"
    oc -n "$1" scale "$2" --replicas=1
  fi
}


# needs jq -> https://github.com/stedolan/jq/releases/tag/jq-1.6
# needs jd -> https://github.com/josephburnett/jd/releases/tag/v1.1
# curl -fsSL https://github.com/josephburnett/jd/releases/download/v1.1/jd -o /usr/local/bin/jd && chmod a+x /usr/local/bin/jd

[ ! -f .env ] && echo ".env file not found!" && exit 1
source .env

[ -z ${TOOLS_NS+x} ] && {echo "Environment Variable 'TOOLS_NS' has not been set or it is empty" && exit 1} || true
[ -z ${DEV_NS+x} ] && {echo "Environment Variable 'DEV_NS' has not been set or it is empty" && exit 1} || true
[ -z ${STUDENT_ID+x} ] && {echo "Environment Variable 'STUDENT_ID' has not been set or it is empty" && exit 1} || true
