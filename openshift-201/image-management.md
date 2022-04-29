# Best Practices of Image Management

## Objectives:

After completing this section, you should have an understanding of the best practices around image management.

## Building Images
Source-to-image (S2I) is a framework that makes it easy to write images that take application source code as an input and proced a new image that runs the assembled application as output.

The main advantage of using S2I is the ease of use for developers.  OpenShift provides base images for the following:
* .NET
* Java
* Go
* Node.js
* Perl
* PHP
* Python
* Ruby

In the following exercise, you will manage application builds with OpenShift, using the source strategy with a Git input source.

The following commands are used to create a new application.  The `myapp` application created is a simple Java Sprint Boot app that will display a message based on environment variables.

### Create a new application 
```bash
oc new-app --name myapp \
-i redhat-openjdk18-openshift:1.8 \
 https://github.com/BCDevOps/devops-platform-workshops \ 
 --context-dir=openshift-201/materials/image-management/sample-app
```

You should see output similar to the follow:
<pre>
...<em>output omitted</em>...
imagestream.image.openshift.io "myapp" created
    buildconfig.build.openshift.io "myapp" created
    deployment.apps "myapp" created
    service "myapp" created
--> Success
...<em>output omitted</em>...
</pre>

As you can see there are a few resources create with the `new-app` command.  One is the `BuildConfig`.  To see the `myapp` `BuildConfig` click on the `Builds -> BuildConfigs` item in the left menu then choose `myapp` and select `YAML` or run `oc get bc/myapp -o yaml`.  You should see something similiar to the following:

![buildconfig](images/image-management/buildconfig.png)

1. Name of BuildConfig
2. Defines the output.  Where the image will go after it is successfully build.
3. The `strategy` section describes the build strategy used to execute the build. You can specify a `Source` , `Docker`, or `Custom` strategy here. This example uses the `redhat-openjdk18-openshift` container image that Source-to-image (S2I) uses for the application build.
4. The `source` section defines the source of the build. The source type determines the primary source of input, and can be either `Git`, to point to a code repository location, `Dockerfile`, to build from an inline Dockerfile, or `Binary`, to accept binary payloads.
5. You can specify a list of triggers, which cause a new build to be created.


### Follow Build
Use the `oc logs` command to chck the build logs from the `myapp` build:
```bash
oc logs -f bc/myapp
```
<pre>
...<em>output omitted</em>...
Writing manifest to image destination
Storing signatures
...<em>output omitted</em>...
Push successful
</pre>

Once the build is complete let's inspect the `ImageStream`.  To do so click on the `Builds -> ImageStreams` item in the left menu then choose `myapp` and select `YAML` or run `oc get is/myapp -o yaml`.  You should see something similiar to the following:

![imagestream](images/image-management/imagestream.png)

1. Name of ImageStream
2. Docker repository path where new images can be pushed to add/update them in this image stream.
3. The image stream tag.  In this case `latest`.
4. The `items` are the associated images to the `latest` tag in this case.  `dockerImageReference` is the SHA identifier that this image stream tag currently references and the `image` is the SHA identifier that this image stream tag previously referenced.  In this case they are the same because we only have one image generation.

### Aplication Status
Wait for the application to be ready and running:
```bash
oc get pods

NAME                    READY   STATUS      RESTARTS   AGE
myapp-1-build           0/1     Completed   0          10m
myapp-85c7dc4569-njqlb  1/1     Running     0          36s
```

### Expose Application
Expose the application to external access:
```bash
oc expose svc/myapp
```

### Test Application
Perform the following command to get the host of the route we just exposed:
```bash
export MY_HOST=`oc get routes myapp --no-headers | awk '{print $2}'`
```

or run `oc get routes myapp` and copy the host name.

Then run the following:
```bash
curl http://$MY_HOST/hello

Hello world from unknown
```

## Application Configuration
The `myapp` application has 2 environment variables that can be set to change the ouput of our `hello` endpoint.
1. `NAME` is who is saying hello
2. `APP_MSG` message to ouput

There are multiple ways to configure these environment variables in OpenShift

### Environment Variables
Environment variables can be set directly on your `Deployement` or `DeploymentConfig`.  

#### Setting Environment Variable
We can set the `NAME` environment variable on our `myapp` deployment by performtion the following:
```bash
oc set env deployment/myapp NAME='YOUR_NAME_HERE'
```

This should automatically redeploy the app.
```bash
oc get pods

NAME                   READY   STATUS              RESTARTS   AGE
myapp-77ff765f49-nsqhc 1/1     Running             0          4m27s
myapp-c97b5b874-zsz2j  0/1     ContainerCreating   0          5s
```

Wait for the new pod to be in the `Running` status.

#### Test Application
We should now see our name when calling our `hello` endpoint

```bash
curl http://$MY_HOST/hello

Hello world from YOUR_NAME_HERE
```

### ConfigMap
