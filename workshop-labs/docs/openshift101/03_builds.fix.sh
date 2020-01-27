#!/usr/bin/env bash

oc -n ${TOOLS_NS} new-build https://github.com/BCDevOps/devops-platform-workshops-labs/ --context-dir=apps/rocketchat --name=rocketchat-${STUDENT_ID} --name=rocketchat-${STUDENT_ID} --dry-run -o json > "${LAB_NUM}-build.json"

echo "Converting List to Template"
convert_list_to_template "${LAB_NUM}-build.json" "rocketchat-${STUDENT_ID}"

_jq '(.objects[] | select(.kind == "BuildConfig")).spec.runPolicy |= "SerialLatestOnly"' "${LAB_NUM}-build.json"

_jq '(.objects[] | select(.kind == "BuildConfig" and .spec.strategy.dockerStrategy !=null)).spec.strategy.dockerStrategy.imageOptimizationPolicy |= "SkipLayers"' "${LAB_NUM}-build.json"

echo "Removing triggers"
_jq 'del(.objects[] | select(.kind == "BuildConfig") | .spec.triggers[] | select(.type == "GitHub" or .type == "Generic" or .type == "ImageChange" or .type == "ConfigChange"))' "${LAB_NUM}-build.json"

echo "Increasing CPU/Memory for the build"
_jq '(.objects[] | select(.kind == "BuildConfig") | .spec.resources) |= {"requests" : {"cpu": "1", "memory": "1Gi"}, "limits": {"cpu": "2", "memory": "2Gi"}}' "${LAB_NUM}-build.json"

echo "Applying Template"
oc -n "${TOOLS_NS}" process -f "${LAB_NUM}-build.json" -l "app=rocketchat-${STUDENT_ID}" | oc -n "${TOOLS_NS}" apply -f -

echo "Building ..."
oc -n "${TOOLS_NS}" start-build "rocketchat-${STUDENT_ID}" --wait

echo oc -n "${TOOLS_NS}" delete all -l "app=rocketchat-${STUDENT_ID}"
