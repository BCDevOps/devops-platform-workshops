# Lab Setup
Prior to working on labs, the Platform Services team will have created 4
projects: 
- tooling
- dev
- test 
- production

One member from your group has been given administrative rights to the projects
and is responsible for adding all other members to each project. 

---
Assign yourself a unique name to be used during your application deployments. 
**Do not copy the application names directly from the lab guides** as you are in a 
shared environment with the rest of your team. 

For example, if the lab says to create an application named `app1-[username]`, I 
would create an app named `app1-stewartshea`. 

## Lab Requirements
These labs will require access to the pathfinder production environment: 
- [Pathfinder Web Console](https://console.pathfinder.gov.bc.ca:8443/console/)


The environment can be accessed from a web browser such as Chrome or Firefox. For 
users that also leverage the CLI, the `oc` binary is available for download [here](https://github.com/openshift/origin/releases/tag/v3.10.0). 
The current version of OpenShift is 3.10 and should be installed into your PATH.

In addition, developers require GIT locally installed and must have a 2FA device to support access to GitHub. 

- To login with the oc utility: 
    - Login to the [Pathfinder Web Console](https://console.pathfinder.gov.bc.ca:8443/console/) with your GitHub ID
    - Navigate to the top right corner, select the drop-down from your username, and select `Copy Login Command`
    - Paste the copied command into your terminal of choice

```
oc login https://console.pathfinder.gov.bc.ca:8443 --token=[token]
```
