# OpenShift 201 Training Labs
Welcome to the OpenShift 201 Training Labs. 
The lab materials in this folder are designed to accompany the OpenShift 201 Workshop.
You may want to reference the [OpenShift 201 Workshop Slides](https://docs.google.com/presentation/d/1h1123AfJx5k9shYZc6JpHdpKbJSt_qcdDf9V_We9qNc) as you work through the lab.


### Prerequisites:
- Previous completion of the OCP101 workshop and lab exercises. You can find the lab material hosted on [this GitHub Page](https://github.com/BCDevOps/devops-platform-workshops/tree/master/101-lab/content). The OpenShift 201 exercises are independent of the 101 exercises. 
- oc CLI installed and up to date, find out [how to here](https://stackoverflow.developer.gov.bc.ca/questions/139)
- You must be a member of the BC Gov github orgs. You would have set this up during the OpenShift 101 lab. 
- An OpenShift project set created for you from Registry app, which you are an Admin of. You will either receive an email about this in advance of the course, or set this up during the OCP201 kick off.
- These instructions assume the use of a bash-based shell such as zsh (included on OS X) or [WSL](https://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/) for Windows. Please set this up prior to the course. 


### Lab topics:

The Openshift 201 Lab is divided into the following topics:
* Openshift Pipelines (you can choose to do either one)
    * [React Application](./react-pipeline.md)
    * [Java Application (Maven)](./pipelines.md)
* [Resource Management](./resource-mgmt.md) 
* [Network Policy & ACS](./network-policy.md)
* [Application Logging with Loki](./logging.md)
* [Best Practices for Image Management](./image-management.md)
* [Pod Auto Scaling](./rh201-pod-auto-scale.md)
* [Post Outage Checkup](./post-outage-checkup.md)
