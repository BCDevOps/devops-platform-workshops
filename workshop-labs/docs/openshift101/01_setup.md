# Lab Setup
Prior to working on labs, the Platform Services team will have created 2
projects:
- ocp101-tools: This namespace will have all of the builds related objects
- ocp101-dev: This namespace will have all the deployment related objects

One member from your group has been given administrative rights to the projects
and is responsible for adding all other members to each project.

NOTE: the actual name of the namespaces may vary, and `ocp101` may be a sequence of random characters.

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
users that also leverage the CLI, the `oc` binary is available for download [here](https://github.com/openshift/origin/releases/tag/v3.11.0).
The current version of OpenShift is 3.11 and should be installed into your PATH.

In addition, developers require GIT locally installed and must have a 2FA device to support access to GitHub.

- To login with the oc utility:
    - Login to the [Pathfinder Web Console](https://console.pathfinder.gov.bc.ca:8443/console/) with your GitHub ID
    - Navigate to the top right corner, select the drop-down from your username, and select `Copy Login Command`
    - Paste the copied command into your terminal of choice

```
oc login https://console.pathfinder.gov.bc.ca:8443 --token=[token]
```

## Team Permissions
Once all projects have been created by the Platform Services team, the team admin
must navigate to each project and assign your users the appropriate permissions. 

As a team, find each project and add the rest of the team members. Feel free to experiment with
the default roles.  

![](../assets/01_projects.png)

- Once in the project, navigate to `Resources -> Membership -> Users`

- Select `Edit Membership`

![](../assets/01_membership.png)

- Add each user based on their GitHub id

![](../assets/01_edit.png)

- Select `Done Editing`


This can also be done on the CLI with the `oc` utility: 

```
oc policy add-role-to-user [role] [username]
```