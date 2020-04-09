set -e

oc -n "${NS_WORKBENCH}" process -f "${SCRIPT_PATH}/templates/role-student.json" | oc -n "${NS_WORKBENCH}" create -f -

oc -n "${NS_WORKBENCH}" create serviceaccount student

echo -e "tools\ndev" | xargs -t -I {} oc -n "${NS_PREFIX}-{}" policy add-role-to-user admin "system:serviceaccount:${NS_WORKBENCH}:student"

oc -n "${NS_WORKBENCH}" process -p "NAMESPACE=${NS_WORKBENCH}" -f https://raw.githubusercontent.com/BCDevOps/platform-services/master/security/aporeto/docs/sample/quickstart-nsp.yaml | oc -n "${NS_WORKBENCH}" apply -f -

("${SCRIPT_PATH}/setup.sh" build-docs)
("${SCRIPT_PATH}/setup.sh" deploy-main-docs)
("${SCRIPT_PATH}/setup.sh" build-workbench)
