#!/usr/bin/env bash
# Usage: Allow to use jq to have the same file as inout and output.
# It expects that the last argument is the file to read/write
# All arguments (except the last one) are forwarded to jq as is
function _jq {
  arg_file="${@: -1}"
  tmp_input_file="$(dirname $arg_file)/_$(basename $arg_file)"
  cp $arg_file "${tmp_input_file}"
  jq "${@:1:$#-1}" "${tmp_input_file}" > "$arg_file"
  rm "${tmp_input_file}"
}

function _gtar {
  for arg in "$@"; do
    case "$arg" in
      --file=*)
          rm -f "${arg#*=}"
        ;;
    esac
  done
  GZIP=-n gtar -cz --format=ustar --numeric-owner --no-acls --no-selinux --no-xattrs --owner=0 --group=0 --numeric-owner --mtime="2019-01-01 00:00Z" --dereference "$@"
}

function _ocb {
  oc -n "${NS_TOOLS}" "$@"
}

function _ocd {
  oc -n "${NS_DEPLOY}" "$@"
}

# $1 Path to file with List of objects
# $2 Name o fthe template
function convert_list_to_template {
  _jq --arg name "$2" '.kind = "Template" | .objects = .items | del(.items) | .labels = {"template": $name} | .metadata.name = $name' "$1"

  #echo "Removing superfluous labels and annotations"
  _jq 'del(.objects[] | .metadata.labels.build)' "$1"
  _jq 'del(.objects[] | .metadata.annotations["openshift.io/generated-by"])' "$1"

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
    oc -n "$1" rollout latest "$2"
    status="$(oc -n "$1" rollout status "$2" &>/dev/null; echo $?)"
  done
  if [ "${status}" != "0"  ]; then
    echo "Failed deploying $2 after ${attempt} attempts :("
    return 1
  fi
}
