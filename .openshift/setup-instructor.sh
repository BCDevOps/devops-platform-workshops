set -e

oc -n "${NS_WORKBENCH}" process -p "NAMESPACE=${NS_WORKBENCH}" -f https://raw.githubusercontent.com/BCDevOps/platform-services/master/security/aporeto/docs/sample/quickstart-nsp.yaml | oc -n "${NS_WORKBENCH}" apply -f -

("${SCRIPT_PATH}/setup.sh" build-docs)
("${SCRIPT_PATH}/setup.sh" deploy-main-docs)
