set -e
echo "Preparing Workbench Deployment Template"

[ -z ${STUDENT_ID+x} ] &&  echo "Environment Variable STUDENT_ID has not been set or it is empty" && exit 1


oc -n "${NS_WORKBENCH}" process -f "${WORKBENCH_DEPLOYMENT_TEMPLATE_PATH}" -l "app=ocp101-labs-${STUDENT_ID}" -l "student=${STUDENT_ID}" -p "NAME=workbench" -p "SUFFIX=-${STUDENT_ID}" -p "IMAGE_NAMESPACE=${NS_WORKBENCH}" -p "IMAGE_NAME=workbench:latest" | oc -n "${NS_WORKBENCH}" apply -f - --overwrite=true

wait_for_deployment "${NS_WORKBENCH}" "StatefulSet/workbench-${STUDENT_ID}"

echo "StatefulSet/workbench-${STUDENT_ID} has been deployed"
