set -e

echo "Deploying Labs for ${STUDENT_ID}"

oc -n "${NS_WORKBENCH}" process -f "${LABS_STUDENT_DEPLOYMENT_TEMPLATE_PATH}" -l "app=ocp101-labs-${STUDENT_ID}" -l "student=${STUDENT_ID}" -p "HOST=ocp101-labs-${NS_WORKBENCH}.pathfinder.gov.bc.ca" -p "NAME=ocp101-labs" -p "SUFFIX=-${STUDENT_ID}" -p "IMAGE_NAMESPACE=${NS_WORKBENCH}" -p "IMAGE_NAME=ocp101-labs:latest" -p "STUDENT_ID=${STUDENT_ID}" -p "NAMESPACE_TOOLS=${NS_TOOLS}" -p "NAMESPACE_DEV=${NS_DEPLOY}" | oc -n "${NS_WORKBENCH}" apply -f - --overwrite=true

wait_for_deployment "${NS_WORKBENCH}" "dc/ocp101-labs-${STUDENT_ID}"

echo "dc/ocp101-labs-${STUDENT_ID} has been deployed"
