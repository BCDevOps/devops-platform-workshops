# OpenShift Project Folder

The workshop training material is currently hosted out of the pathfinder cluster inside of the `wpvqx7-prod` (devops-workshops (prod)) project.

## Workshop Contents and Labs

2 application images can be deployed from this repo, each with their own directory: 

### workshop-labs

This folder has the content to create an OpenShift compatible `GitBook` based application (docker image) that hosts the desired lab content for students to use during a workshop.  This image does NOT need to be re-built to incorporate content changes, rather, a re-deploy will pull the latest content based on the environment variable configuration.  To support running multiple courses overlapping, ensure that a branch is created for your course, and then add a "-a|b|c" to the deployment SUFFIX.

Example URL: <http://ocp101-labs-a.pathfinder.gov.bc.ca/>

Create your parameter file and run the following to deploy (assuming the base image is available)

``` bash
oc process -f ./provisioning_tools/openshift/ocp-lab-template.yaml \
 --param-file=./provisioning_tools/openshift/sample-lab.env | oc apply -f -
```

### workshop-material

This folder has the content to create an OpenShift compatible `RevealJS` based application that hosts the desired material for instructors to deliver during a workshop.  Each course will require it's own deployment with the specific course detail configured in the deployment environment variables.

Example URL: <http://ocp101-content.pathfinder.gov.bc.ca/>

``` bash
oc process -f ./provisioning_tools/openshift/ocp-content-template.yaml \
 --param-file=./provisioning_tools/openshift/sample-content.env | oc apply -f -
```

## Building Images

buildConfigs are located in the -tools namespace and are created as per the following:

``` bash
oc new-build --name workshop-content https://github.com/BCDevOps/devops-platform-workshops.git \
 --context-dir workshop-material
oc new-build --name workshop-labs https://github.com/BCDevOps/devops-platform-workshops.git \
 --context-dir workshop-labs
```

The default image tag used by the deployments is "v2-stable", and will need to be added after the build.

``` bash
oc tag workshop-content:latest workshop-content:v2-stable
oc tag workshop-labs:latest workshop-labs:v2-stable
```

