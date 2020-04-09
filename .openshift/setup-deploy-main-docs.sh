set -e
echo "Deploying Docs"

oc -n "${NS_WORKBENCH}" process -f "${LABS_MAIN_DEPLOYMENT_TEMPLATE_PATH}" -l "app=ocp101-labs" -p "HOST=ocp101-labs-${NS_WORKBENCH}.pathfinder.gov.bc.ca" -p "NAME=ocp101-labs" -p "SUFFIX=" -p "IMAGE_NAMESPACE=${NS_WORKBENCH}" -p "IMAGE_NAME=ocp101-labs:latest" | oc -n "${NS_WORKBENCH}" apply -f - --overwrite=true

wait_for_deployment "${NS_WORKBENCH}" "dc/ocp101-labs"

echo "dc/ocp101-labs has been deployed"