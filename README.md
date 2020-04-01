# OpenShift Project Folder

The workshop training material is currently hosted out of the pathfinder cluster inside of the `wpvqx7-prod` (devops-workshops (prod)) project. In addition the labs can be built and deployed in
any namespace. 

## Workshop Contents and Labs

2 application images can be deployed from this repo, each with their own directory: 

### workshop-labs

This folder has the content to create an OpenShift compatible `GitBook` based application (docker image) that hosts the desired lab content for students to use during a workshop.  This image does NOT need to be re-built to incorporate content changes, rather, a re-deploy will pull the latest content based on the environment variable configuration. A Configmap with GitBook summary files is required to enable dynamic lab contents, refer to [Slow Release](workshop-labs/README.md) for details. To support running multiple courses overlapping, ensure that a branch is created for your course, and then add a "-a|b|c" to the deployment SUFFIX.

Example URL: <https://ocp101-labs.pathfinder.gov.bc.ca/>

Create your parameter file and run the following to build and deploy the labs. 
> Please note deploying the different workshops labs relies on two things:
1. The `WORKSHOP_NAME` parameter to be set accordingly. [more info](provisioning_tools/openshift/sample-lab.env)
2. The Lab `Dockerfile` to include a gitbooks installation for the workshop

``` bash
oc process -f ./provisioning_tools/openshift/ocp-lab-template.yaml \
 --param-file=./provisioning_tools/openshift/sample-lab.env | oc apply -f -
```

When workshop is finished and not needed anymore, make sure to delete the instance

``` bash
oc get all,configmap -l course-session=<lab session label>
oc delete all,configmap -l course-session=<lab session label>
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
```

The default image tag used by the deployments is "v2-stable", and will need to be added after the build.

``` bash
oc tag workshop-content:latest workshop-content:v2-stable
```

## Adding New Labs

Adding new 'workshop labs' requires a few steps.

1. Create a new directory under `workshop-labs/docs/<lab name>`
2. Add your content following the lab [creation style guide](workshop-labs/Lab-Content-Style-Guide.md)
3. Add a master/summary table of contents for the labs in `workshop-labs/summaries`
4. Update the `Dockerfile` to install gitbooks for the labs (this is not ideal and i'd love for a PR to improve this process)
