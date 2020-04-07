## OCP 201 Lab Installation
1. Fork and Clone this repository into your local workstation
1. Navigate to your lab __Tools__ namespace
4. Process the build deployment template (please modify the following code examples parameters)
```bash
oc process -f ./provisioning_tools/openshift/ocp-lab-template.yaml -p APP=ocp201 -p SUFFIX="yyyy-dd-mm" -p WORKSHOP_NAME=openshift201 -p IMAGE_TAG=latest -p IMAGE_NAMESPACE=[tools namespace] -p GIT_URL=[your repository] | oc apply -f -
```

