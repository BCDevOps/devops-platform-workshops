# Builds
In this lab, you will create a simple Docker based build for the Rocket Chat application. 

### Team Permissions
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

#### The Tools Project
The tools project is what will hold various support tools for the application. In this case, 
Jenkins will run here (later), and all builds will run in this project. 

#### Creating a Docker-Based Build
The Rocket.Chat application build will be based off a minimal Dockerfile in a [public repository](https://github.com/BCDevOps/devops-platform-workshops-labs/tree/master/apps/rocketchat). 
Leveraging the commandline, you can use the `oc new-build` command to create all of the necessary 
OpenShift build components. 

Ensure that all team members have edit rights into the project. Once complete, 
each member can create their own Rocket.Chat docker build. 

- To start, switch to your new project

```
oc project [project-name]
```
- With the `oc` cli, create the build

```
oc new-build https://github.com/BCDevOps/devops-platform-workshops-labs/ --context-dir=apps/rocketchat --name=rocketchat-[username]
```

- The output of the previous command should be similar to the following: 

```

--> Found Docker image c71b6c4 (4 weeks old) from registry.access.redhat.com for "registry.access.redhat.com/rhscl/nodejs-8-rhel7"

    Node.js 8 
    --------- 
    Node.js 8 available as container is a base platform for building and running various Node.js 8 applications and frameworks. Node.js is a platform built on Chrome's JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.

    Tags: builder, nodejs, nodejs8

    * An image stream will be created as "nodejs-8-rhel7:latest" that will track the source image
    * A Docker build using source code from https://github.com/BCDevOps/devops-platform-workshops-labs/ will be created
      * The resulting image will be pushed to image stream "rocketchat-[username]:latest"
      * Every time "nodejs-8-rhel7:latest" changes a new build will be triggered

--> Creating resources with label build=rocketchat-[username] ...
    imagestream "nodejs-8-rhel7" created
    imagestream "rocketchat-[username]" created
    buildconfig "rocketchat-[username]" created
--> Success
    Build configuration "rocketchat-stewartshea" created and build triggered.
    Run 'oc logs -f bc/rocketchat-[username]' to stream the build progress.
```

- You can now explore the Web Console to watch the build status from `Builds -> Builds`
*note* you will see multiple builds from each team member

![](../assets/01_builds.png)

- Or this can be done on the CLI

```
oc get bc
oc status
```

- The build status can be monitored from the Web Console by selecting  the `View Logs` link

![](../assets/01_build_logs.png)
![](../assets/01_build_logs_02.png)
