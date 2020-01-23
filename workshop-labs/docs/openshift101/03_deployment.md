# Deployment
Since the build and deploy stages are separate, and we have a built image, we can deploy this 
image into our remining project spaces. 

#### Create an Image-Based Deployment
Navigate to the configured `dev` project and deploy an image. 

- From the Overview tab, select `Deploy Image`, or from the top right corner from the drop down `Add to Project`

![](../assets/03_deploy_image_01.png)

- Select the tools project, the your specific rocketchat image, and the appropriate tag

![](../assets/03_deploy_image_02.png)
![](../assets/03_deploy_image_03.png)

- Or do this from the CLI

```
oc new-app [devops-training-namespace]-tools/rocketchat-[username]:dev --name=rocketchat-[username]
```

- If performed with the CLI, the output should be as follows

```
--> Found image b949f08 (2 hours old) in image stream "[devops-training-namespace]-tools/rocketchat-[username]" under tag "dev" for "[devops-training-namespace]-tools/rocketchat-[username]:dev"

    Node.js 8 
    --------- 
    Node.js 8 available as container is a base platform for building and running various Node.js 8 applications and frameworks. Node.js is a platform built on Chrome's JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.

    Tags: builder, nodejs, nodejs8

    * This image will be deployed in deployment config "rocketchat-[username]"
    * Ports 3000/tcp, 8080/tcp will be load balanced by service "rocketchat-[username]"
      * Other containers can access this service through the hostname "rocketchat-[username]"
    * This image declares volumes and will default to use non-persistent, host-local storage.
      You can add persistent volumes later by running 'volume dc/rocketchat-[username] --add ...'

--> Creating resources ...
    imagestreamtag "rocketchat-[username]:dev" created
    deploymentconfig "rocketchat-[username]" created
    service "rocketchat-[username]" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose svc/rocketchat-[username]' 
    Run 'oc status' to view your app.
```
- 


#### Troubleshoot Image Pull Access
As the Web UI indicated, the `dev` project service accounts do not have the appropriate access to pull the image from the `tools`
project. 

- Navigate to `Applications -> Pods` and investigate further

![](../assets/03_deploy_image_04.png)

- Navigate to the pods `Events` tab for more detail

![](../assets/03_deploy_image_05.png)

#### Create Proper Access Rights Across Projects
Any team member with admin rights on the `tools` project can create the appropriate permissions for each other project. 

- From the Web Console

![](../assets/03_deploy_image_06.png)

- From the CLI: 

```
oc policy add-role-to-user system:image-puller system:serviceaccount:[devops-training-namespace]-dev:default -n [devops-training-namespace]-tools
oc policy add-role-to-user system:image-puller system:serviceaccount:[devops-training-namespace]-test:default -n [devops-training-namespace]-tools
oc policy add-role-to-user system:image-puller system:serviceaccount:[devops-training-namespace]-prod:default -n [devops-training-namespace]-tools
```

With the appropriate access in place, redeploy the application. 
- From the Web Console

![](../assets/03_deploy_image_07.png)

- OR from the CLI

```
oc rollout latest rocketchat-[username]
```
- Validate that the image is able to be pulled

### Deploying the Database
Before going into further deployment configuration options, review the current status of the application container.  

#### Troubleshoot Deployment Issues
Navigate to the pod and review the logs to determine why we the container will not start. 

- From the Web Console navigate to `Applications -> Pods -> rocketchat-[username]-[randomid]` and select Logs

![](../assets/03_deploy_image_08.png)

- Or from the CLI

```
oc get pods  | grep rocketchat-[username]
oc logs rocketchat-[username]-[randomid]
```
*note* you can follow the logs with `oc -f`


#### Create Mongo Database with Ephemeral Storage
Having identified that the application is trying to connect to a mongo database, add a mongo database to the project
for your application. 

- From the Web Console
    - From the `Add to Project` dropdown, select `Browse Catalog`
    - In the search catalog area, type `mongo` and select `mongodb-ephemeral`
    - Ensure to customize the details with a service name such as `mongodb-[username]`, username/password and default database such as `rocketchat`

![](../assets/03_deploy_mongo_01.png)
![](../assets/03_deploy_mongo_02.png)
![](../assets/03_deploy_mongo_03.png)
![](../assets/03_deploy_mongo_04.png)
![](../assets/03_deploy_mongo_05.png)

- Bonus: determine how to create this from the CLI

### Deployment Configuration Options
As a result of using a generic `new-app` style deployment, as opposed to openshift specific templates, a lot of defaults are leveraged. 

### Environment Variables
By default we currently have no environment variables attached to our deployment configuration. So, while the app trying to start, and 
a database has been deployed, the app does not know how or where to connect to. Add an environment variable to the deployment configuration. 

- In the Web Console, navigate to `Applications -> Deployments`, and select your rocketchat deployment
- Select the `Environment Tab`
- Add the following environment variable with the connection string details configured for mongodb
![](../assets/03_deploy_config_01.png)
  ```
  MONGO_URL=mongodb://dbuser:dbpass@mongodb-[username]:27017/rocketchat
  ```
  you can also use the CLI to apply the environment variable
  ```
  oc -n ocp101-dev set env dc/rocketchat-[username] "MONGO_URL=mongodb://dbuser:dbpass@mongodb-stewartshea:27017/rocketchat"
  ```
- Click save and take note of what happens next
    - Navigate to `Applications -> Pods` and `Applications -> Deployments` to notice the changes
![](../assets/03_deploy_config_02.png)
![](../assets/03_deploy_config_03.png)

While you are waiting for the application to redeploy, expose the route to the public internet.
- From the Web Console, navigate to `Applications -> Routes`
- Select `Create Route`
    - Customize the name of the route, such as `rocketchat-[username]`
    - Ensure the service it points to is your particular service
![](../assets/03_deploy_route.png)

### Exploring Health Checks
With the new deployment running, monitor the readiness of the pod. 
- Navigate to `Applications -> Pods`
- Notice that `1/1` containers are ready
![](../assets/03_deploy_health_01.png)

- Visit the application route, however, and notice that the application is not ready
![](../assets/03_deploy_health_02.png)


#### Adding a Healthcheck
A container that is marked `ready` when it is not is an indication of a lack of (or misconfigured) healthcheck. 
Let's add a healthcheck. 

- Navigate to `Applications -> Deployments`
- Select the appropriate deployment
- Select `Actions` and then `Edit Health Checks`

![](../assets/03_deploy_health_03.png)

- Select `Add Readiness Probe` and leverage the HTTP GET defaults for this application, setting an initial delay of 15 seconds
![](../assets/03_deploy_health_04.png)

- While the new deployment rolls out, continue to refresh the public route and validate that it stays up
- At the same time, monitor the pod `Containers Ready` column from `Applications -> Pods` and notice what happens when it becomes ready

### Exploring Deployment Configuration Options
Additional actions are avalable to edit your deployment configuration. Review and explore; 
- Resource Limits
- Healthcheck liveliness probes
- YAML 

#### Versioning a Deployment Configuration
At this point in time, your deployment configuration has undergone many changes, such as adding environment variables and adding health checks. 
Review the deployment configuration `History` tab: 
- Select Deployment #1, right-click, and open in a new tab
- Select your latest deployment version, right-click, and open in a new tab
- Compare the differences - this can be done through the UI or by comparing the YAML

#### Changing Deployment Configuration Triggers
While reviewing the different deployment versions, take note of the `Trigger` column. 

![](../assets/03_deploy_versions.png)

- Navigate to the `Configuration` tab of the deployment and review the currently configured Triggers

![](../assets/03_deploy_triggers.png)

Explore how an Image can also trigger a deployment
- Navigate to your original build and investigate the available triggers

![](../assets/03_deploy_build_trigger_01.png)

- Edit the buildconfig to change the output image to the `dev` tag

![](../assets/03_delploy_build_trigger_02.png)

- Start a new build and monitor your the `dev` deployment when the build completes

![](../assets/03_deploy_build_trigger_03.png)

#### Changing the Deployment Strategy Option
The default deployment configuration provides a `Rolling Update` style deployment, which waits for the container to be ready prior to 
cutting over traffic and terminating the previous container. 

![](../assets/03_deployment_strategy_01.png)

- Change the strategy to a `Recreate` and redeploy a couple of times
- Refresh the browser URL right after a new deployment and observe the behavior
- Change the strategy back to `Rolling`
