# Deployment
Since the build and deploy stages are separate, and we have a built image from the previous exercise, we can now deploy this 
image into the dev project. 

## The Dev Project
The dev project is where applications are deployed. In this case, we will deploy RocketChat and MongoDB to the dev namespace.

### Create an ImageStreamTag


> Although we use the tag name `dev` there are better naming conventions! We strongly suggest associating image tags with a version that is meaningful for your project!

- From the CLI

```oc:cli
# retagging the image stream from latest to dev
oc -n [-tools] tag rocketchat-[username]:latest rocketchat-[username]:dev

# Verify that the `dev` tag has been created
oc -n [-tools] get imagestreamtag/rocketchat-[username]:dev
```

## Create an Image-Based Deployment

__Objective__: Deploy RocketChat from the image previously built.

- from the CLI

```oc:cli
oc -n [-dev] new-app [-tools]/rocketchat-[username]:dev --name=rocketchat-[username]
```

- The output should be as follows

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
      You can add persistent volumes later by running 'volume deployment/rocketchat-[username] --add ...'

--> Creating resources ...
    imagestreamtag "rocketchat-[username]:dev" created
    deployment "rocketchat-[username]" created
    service "rocketchat-[username]" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose svc/rocketchat-[username]' 
    Run 'oc status' to view your app.
```

## Speed-up application startup
__Objective__: Get RocketChat to startup faster by tweaking `Resource Requests and Limits`.

> Resource adjustment is also something that will be covered in a later exercise

Increasing the resources (especially CPU) right now will help with faster pod startup.

- From the terminal, run the follow oc command:
```oc:cli
oc -n [-dev] set resources deployment/rocketchat-[username] --requests='cpu=500m,memory=512Mi' --limits='cpu=1000m,memory=1024Mi'
```

## __Objective 1__: Identify ImagePull Problem
As the Web UI indicated, the `dev` project service accounts do not have the appropriate access to pull the image from the `tools`
project. Admin users manage service accounts and will need to grant rolebindings in order to provide image pull access from two respective namespaces.

Note that since only admin users have access to manage rolebindings in a namespace, the following action will need to be done by DevOps in the team. Reach out to the team if you don't have access to do so! This step only needs to be completed once for the shared namespace that the lab class is working in. If somebody else has completed this step already and you're not experienceing the ImagePull error, move on to the next step _Objective 2_. 

- Navigate to `Topology` and click on the deployment to investigate further

![](./images/03_deploy_image_04.png)

- Click on the pod within the deployment and navigate to the pods `Events` tab for more detail

![](./images/03_deploy_image_05.png)


Now that we have identified the issue, next step is to create the rolebinding to allow image pulling from tools namespace.

> Note that only Admin users have access to manage rolebindings in a namespace, the following action will need to be done by DevOps in the team. Reach out to the team if you don't have access to do so!

- From the CLI add a service account to tools granting image pull access to the from the dev project: 

```oc:cli
oc -n [-tools] policy add-role-to-user system:image-puller system:serviceaccount:[-dev]:default
```
_ Remember:  if somebody else in the lab has completed this step already and you're not experienceing the ImagePull error, move on to the next step _Objective 2_.

With the appropriate access in place, you can try bringing up a new pod to see if the issue has been resolved. With Deployments this can be done by
`oc -n [-dev] scale deployment/rocketchat-[username] --replicas=0` waiting for the pods to scale down to 0 and then to scale back up with `oc scale -n [-dev] deployment/rocketchat-[username] --replicas=1`

- Validate that the image is able to be pulled

## __Objective 2__: Importing Images to the deploy namespace

Deploying images from another namespace can run you into some issues that are easily solvable if you import a copy of the image to your deploy namespace. This is a BC Gov best practice in fact. 

### Why Build in Tools Then?

Your Tools namespace has quota that can be best utilized for your CI (Continuous Integration) and devops workloads. Since building an image is apart of the CI pipeline you can run your builds there without impacting the cpu or memory availability for deployment workloads. 

When you ran `oc new-app` a new imagestream was created in your `dev` namespace with an image that points to your `tools` namespace. To import the image from one namespace to another you can:

1. Re-tag your tools image tag into this new imagestream

`oc -n [-dev] tag [-tools]/rocketchat-[username]:dev rocketchat-[username]:dev`

2. Modify your Rocket Chat deployment to point to the new image stream.
`oc -n [-dev] set image deployment/rocketchat-[username] rocketchat-[username]=rocketchat-[username]:dev`

## __Objective 3__: Identify CrashLoopBackOff problem

Notice that the deployment is still failing. 

![](./images/03_deploy_image_08a.png)

Navigate to the pod and review the logs to determine why the container will not start. 

From the console click the deployment config and click __view logs__ beside the failing pod

![](./images/03_deploy_image_08b.png)

- Or from the CLI

```oc:cli
# Show your pod's log
oc -n [-dev] logs -f "$(oc -n [-dev] get pods --field-selector=status.phase=Running -l deployment=rocketchat-[username] -o name --no-headers | head -1)"
```
*note* you can follow the logs with `-f` argument

Taking a look at the logs it is clear that the RocketChat pod is failing because it is not able to connect to a __mongo database__.

## Deploying the Database


### Create Mongo Database with Ephemeral Storage
Having identified that the application is trying to connect to a mongo database, add a mongo database to the project
for your application. 

### From CLI
  - Find out what 'mongodb-ephemeral' is

```oc:cli
oc -n [-dev] new-app --search mongodb-ephemeral
```

  - The output will tell us that `mongodb-ephemeral` is a template in the `openshift` project:

```
-----
mongodb-ephemeral
  Project: openshift
  MongoDB database service, without persistent storage. For more information about using this template, including OpenShift considerations, see https://github.com/sclorg/mongodb-container/blob/master/3.2/README.md.

WARNING: Any data stored will be lost upon pod destruction. Only use this template for testing
```

  - List available parameters of the template

```oc:cli
oc -n openshift get template/mongodb-ephemeral -o json | oc process -f - --parameters=true
```

  - Create MongoDB based on a template in the catalog

```oc:cli
  oc -n [-dev] new-app --template=openshift/mongodb-ephemeral -p MONGODB_VERSION=3.6 -p DATABASE_SERVICE_NAME=mongodb-[username] -p MONGODB_USER=dbuser -p MONGODB_PASSWORD=dbpass -p MONGODB_DATABASE=rocketchat --name=rocketchat-[username]
```
> If you ran the cli command you would get an output like this 
  ```
  Creating resources ...
      secret "mongodb-patricksimonian" created
      service "mongodb-patricksimonian" created
      deployment.apps.openshift.io "mongodb-patricksimonian" created
  --> Success
      Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
      'oc expose svc/mongodb-patricksimonian' 
      Run 'oc status' to view your app.
  ```

### From the Web Console

  - From the side menu click `+Add`, then select `From Catalog`

  - In the search catalog area, type `mongo` and select `mongodb-ephemeral`
  - Click Instantiate Template
  - Ensure to customize the details with a service name such as `mongodb-[username]`, username/password and default database such as `rocketchat`

![](./images/03_deploy_mongo_01.png)
![](./images/03_deploy_mongo_02.png)
![](./images/03_deploy_mongo_03.png)

### Verify MongoDB is up
  - Find the mongodb deployment by going back to `Topology`
  - Wait until MongoDB has been successfully deployed
  MongoDB will generate a lot of logs. Since MongoDB comes with a readiness probe check for pod/container readiness, to know when it is up and ready.
  
  You can safely ignore repeated messages as such:
  ```
  2020-02-06T06:23:41.391+0000 [conn11041]  authenticate db: rocketchat { authenticate: 1, nonce: "xxx", user: "dbuser", key: "xxx" }
  ```

### Deployment Configuration Options
As a result of using a generic `new-app` style deployment, as opposed to openshift specific templates, a lot of defaults are leveraged. 

### Environment Variables
By default your rocketchat deployment has no environment variables defined. So while RocketChat is trying to start and 
a database has been deployed, the app does not know how or where to connect to MongoDB. We will need to add environment variables to the deployment configuration.

- In the Web Console, navigate to `Topology` and select your rocketchat deployment
- Click on the name of your rocketchat-[username] deployment in the right-hand menu pane
- Click the `Environment` tab
![](./images/03_deploy_env_02.png)

- Add the following environment variable with the connection string details configured for mongodb
```
MONGO_URL=mongodb://dbuser:dbpass@mongodb-[username]:27017/rocketchat
```
![](./images/03_deploy_config_01.png)

 
You can also use the CLI to apply the environment variable.
```
oc -n [-dev] set env deployment/rocketchat-[username] "MONGO_URL=mongodb://dbuser:dbpass@mongodb-[username]:27017/rocketchat"
```

- Click Save 
- Navigate to `Topology` and investigate your RocketChat Deployment Config. It should be redeploying (successfully this time)


#### STRETCH: Sensitive Configurations
> this is a stretch exercise, completing this section is not a requirement for the next section of the lab

If you are feeling at odds with things like __dbpass__ being out in the open as an environment variable. That is a good thing! For demonstration purposes you are creating a `Single Value Env`. Sensitive information like passwords should be stored in a `Secret` and referenced as `envFrom`. In addition, you can also use the [Downward API](https://docs.openshift.com/container-platform/4.4/nodes/containers/nodes-containers-downward-api.html#nodes-containers-downward-api-container-secrets_nodes-containers-downward-api) to refer to the secret created by MongoDB.
  ```oc:cli
  oc -n [-dev] rollout pause deployment/rocketchat-[username] 

  oc -n [-dev] patch deployment/rocketchat-[username] -p '{"spec":{"template":{"spec":{"containers":[{"name":"rocketchat-[username]", "env":[{"name":"MONGO_USER", "valueFrom":{"secretKeyRef":{"key":"database-user", "name":"mongodb-[username]"}}}]}]}}}}'

  oc -n [-dev] patch deployment/rocketchat-[username] -p '{"spec":{"template":{"spec":{"containers":[{"name":"rocketchat-[username]", "env":[{"name":"MONGO_PASS", "valueFrom":{"secretKeyRef":{"key":"database-password", "name":"mongodb-[username]"}}}]}]}}}}'

  oc -n [-dev] set env deployment/rocketchat-[username] 'MONGO_URL=mongodb://$(MONGO_USER):$(MONGO_PASS)@mongodb-[username]:27017/rocketchat'

  oc -n [-dev] rollout resume deployment/rocketchat-[username] 

  # Check environment variables configuration
  oc -n [-dev] get deployment/rocketchat-[username] -o json | jq '.spec.template.spec.containers[].env'
  ```

## Create a Route for your Rocket.Chat App
Your rocketchat application should already have a route created for it. If you were using `oc new-app` however, a route would not have been created by default. 

### CLI

There are 2 ways of creating routes using CLI.

  - Using `oc expose` for unsecure (http) route
```
oc -n [-dev] expose svc/rocketchat-[username]
```
  - Using `oc create route` for secure (https) route
  
```oc:cli
oc -n [-dev] create route edge rocketchat-[username] --service=rocketchat-[username] --insecure-policy=Redirect
```

After creating the route you may access your application! 
![rocketchat](./images/03_deploy_route.png)

<!-- 
not sure how to navigate to routes from web console in ocp4
### Web Console
  
  - Select `Create Route`
    - Customize the name of the route, such as `rocketchat-[username]`
    - Ensure the service it points to is your particular service
![](./images/03_deploy_route.png) -->

## Exploring Health Checks

- If you redeploy the rocket chat application there is an interval where the pod is considered ready but it is still not available to be accessed.
- You can check this by killing the pod, waiting for the pod to redeploy and be `ready` and then visit your
Rocket Chat url. 




![](./images/03_deploy_pod_delete_01.png)
![](./images/03_deploy_pod_delete_02.png)



### Adding a Healthcheck
A container that is marked `ready` when it is not is an indication of a lack of (or misconfigured) healthcheck. 

You can add a healthcheck for `readiness` and `liveness`. 

### Using cli
```oc:cli
oc -n [-dev] set probe deployment/rocketchat-[username] --readiness --get-url=http://:3000/ --initial-delay-seconds=15

```


### Summary

You added a __readiness__ check to the `rocketchat-[username]` deployment so that you no longer have a false positive of when the pod should be considered available. By default pods are considered to be 'ready' when the container starts up and the entrypoint script is running. This however is not useful for things like webservers or databases! Not only do you need the entrypoint script to run but you need to wait for the server to listen on a port. 

Next page - [Configuring Deployments](./04_configuring_deployments.md)
