# Lab Setup
Prior to working on labs, the Platform Services team will have created 3
projects for each attendee:
- tools
- dev
- prod

Each attendee is provided their own dedicated project as a platform "tenant". In this way, attendees are not required to add customized names to their apps, as was the case in OpenShift101.

---

## Lab Requirements
These labs will require access to the pathfinder production environment:
- [Pathfinder Web Console](https://console.pathfinder.gov.bc.ca:8443/console/)


The environment can be accessed from a web browser such as Chrome or Firefox. For
users that also leverage the CLI, the `oc` binary is available for download [here](https://github.com/openshift/origin/releases/tag/v3.11.0).
The current version of OpenShift is 3.11 and should be installed into your $PATH.

In addition, attendees require GIT locally installed and must have a 2FA device to support access to GitHub.

- To login with the oc utility:
    - Login to the [Pathfinder Web Console](https://console.pathfinder.gov.bc.ca:8443/console/) with your GitHub ID
    - Navigate to the top right corner, select the drop-down from your username, and select `Copy Login Command`
    - Paste the copied command into your terminal of choice

```
oc login https://console.pathfinder.gov.bc.ca:8443 --token=[token]
```

## Communication Resources
The lab instructors will open up a dedicated RocketChat channel for sharing of code, content, or discussions for the duration of this class.
Please provide the instructors with your RocketChat user id at the same time as your GitHub ID when starting the workshop.
