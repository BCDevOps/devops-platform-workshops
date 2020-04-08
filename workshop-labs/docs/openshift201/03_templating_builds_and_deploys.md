# Templating Custom Applications

Earlier Helm was used to retrieve templates for products like Prometheus and Grafana. On the cluster though,
you will also be building your applications. How do we convert the infrastructure needed to run your application
into templates?


## Creating Templates For S2I Builds & Deploys

It is always a great idea to try and get your builds and deploys working correctly before converting them to templates. 

In this repository there is a sample __express api__ application that you will build and deploy. It can be
located at `demo-express-server` from the root of this repository. 


## Creating A New Build and Extracting the Infrastructure Code

Create a new build using `oc new-build` in the __tools__ namespace for the `demo-express-server` app.

> using the `--dry-run` flag will allow you to check if your commands would run correctly in openshift. In addition it allows you to capture your infrastructure as code without having to actually run the build immediately. `--dry-run` can also be used during deployments.

1. Create the build `oc -n <tools namespace> new-build https://github.com/bcdevops/devops-platform-workshops --context-dir=demo-express-server --name=joke-api --dry-run`

2. Observe that the build _would have_ worked correctly
<asset here>

3. Remove the `--dry-run` flag to run the build for real this time

4. Observe the build is running with `oc describe -n <tools namespace> bc/joke-api`
 <asset here>
Wait for the build to complete before continuing to step 5.

5. Prior to storing any infrastructure code, there will need to be a place to store it in. As a __BC Gov__ best practice, infra code should be stored in an `openshift` directory at the root of your project. Create a new directory called `openshift`, if it doesn't already exist, and the sub-directory `demo-express-server` within it.

6. Extract the __buildconfig__ & __imagestream__ infrastructure as code so that it can be converted into a template

  a. Since you will be working in the tools namespace for sometime, it will be easier to switch into it. Run `oc project <toolsnamespace>`

> Applying the `--name=` flag with `oc new-build` automatically created a label `build=joke-api`. This label,
plus other labels that you will want to apply will make it easy to query and modify your infrastructure objects later. 


  b. Run `oc get all -l build=joke-api --export=true -o yaml > openshift/demo-express-server/build-infra.yaml` to extract a __stdout__ version  of your infrastructure code and write it to a file. 

> As a bcgov best practice we recommend storing your infrastructure code as `YAML` format. It is easy to read, and allows you to add comments to the code.

> `oc get all` does not get __all__ openshift objects. Some objects that are __not__ queried include: pvcs,
configmaps, secrets, rolebindings

7. Explore the build infrastructure code. 

## We Done Yet? 

Nope! This is far from being ready to be consumed by a pipeline.

## Clearing up the Garbage

When you ran `oc get all -l build=joke-api --export=true` it grabbed an __Imagestream__, the __BuildConfig__, and all __Build__ objects. __Build__ objects are created __from BuildConfigs__, for this reason they should be not included as apart of your infra code.

Delete the __Build__ object from the `build-infra.yaml` file.
> you could also run `oc get buildconfig,imagestream -l build=joke-api --export=true -o yaml > openshift/demo-express-server/build-infra.yaml` instead :D


In addition to grabbing Objects that __are not needed as apart of infra code__. There are annotations that
__k8s__ applies to objects that are not needed as code. Things like `metadata.selfLink`, `metadata.creationTimestamp`, `metadata.uid` are not needed. Delete those from the __ImageStream__ and __BuildConfig__ objects.

You can also delete `ImageStream.status` as well. 

## Improving the BuildConfig

The build config is missing a few __BC Gov__ best practices.

1. Add resource request/limits to the build config.

Your tools namespace has a set amount of quota. At this time it is __8 cores__ of cpu and __32 Gb__ of memory. 
Adding requests/limits to a build config will allow you to effectively manage your quota.

  a. Run the command `oc explain buildconfig` to understand what configuration fields are available for __BuildConfig__. 
  
  b. To drill further down into nested fields of a __BuildConfig__ you can chain on terms to the original command. Run `oc explain buildconfig.spec`.

  c. Investigate where to add resources/requests. Run `oc explain bc.spec.resources`.

  d. Add these resources to your `build-infra.yaml` under `spec`

```yaml
resources:
  requests:
    cpu: 200m
    memory: 120Mb
  limits:
    cpu: 350m
    memory: 230Mb
```

2. Delete all objects related to the build and try the build again
  a. `oc delete all -l build=joke-api` 
  b. `oc apply -f openshift/demo-express-server/build-infra.yaml`
  c. `oc start-build bc/joke-api`

      __Stretch Activity__: Tuning resources is challenging and highly depends on your application. 
      Try ___under provisioning__ your build config to see what would happen if it didn't have enough
      resources to complete the job. Try under provisioning `cpu` and `memory` separately and investigate
      the issues that arise. Again, now that you have your infrastructure as code you should be able to make
      changes and run `oc apply` and `oc start-build`.

3. Add labels to the BuildConfig so that it is easier to query.
  a. Go to your `build-infra.yaml` and edit the __ImageStream__ and __BuildConfig__ objects to contain the labels
  `app: joke-api`, `project: joker-app`, `team: <your team name>`
  b. `oc delete all -l build=joke-api` and `oc apply -f openshift/demo-express-server/build-infra.yaml` to push these changes to your namespace
  c. Check to see if you can correctly query objects by that label. `oc get all -l app=joke-api`


4. Change the output image tag to __NOT BE LATEST__. Instead change the __BuildConfig__ output field to

```yaml
output:
  to:
    kind: ImageStreamTag
    name: joke-api:dev
```
> the latest tag will run you into trouble. Avoid using latest for any image references.
## Reproducing BuildConfigs by Template

Right now the BuildConfig and ImageStream have been captured but will only create one __particular instance__ of the infrastructure code. It is more beneficial to __templatize__ the BuildConfig and ImageStream. When in a __Template__ it is possible to add __parameters__ to the config. This will make the infracode more easily integrated into a pipeline.

## Manually Converting to a Template

When the command run `oc get` was run it created an Openshift object called __List__. A __List__ is very similar
to a __Template__ in that it contains a list of Openshift Objects. 

1. Open up the `build-infra.yaml` file and modify it into a __Template__
  a. Replace `kind: List` with `kind: Template`
  b. Replace `items:` with `objects:`

<!-- ocp201 list and template images here -->
2. Check that your template is working correctly. `oc process -f openshift/demo-express-server/build-infra.yaml -o yaml`. It should output the YAML code if it is working correctly. 

## Adding Parameters

Perfect. There is a working template but it still only creates a __single instance__ of your build 
infrastructure. The power of __Template__ objects is that you can add parameters. `oc explain Template.parameters`.

1. Add a Parameter called `IMAGE_SUFFIX` to the template so that you control the type of output image. 
```yaml
parameters:
- name: IMAGE_SUFFIX
  required: true
  default: dev
  description: the image tag suffix but is also used to suffix labels
```

<!-- ocp201 parameters image here -->

2. Apply the parameter to the __label__ `app: joker-api` and the __output__ image tag

```yaml
labels:
  build: joke-api
  app: joke-api-${IMAGE_SUFFIX}
  project: joker-app
```

```yaml
output:
  to:
    kind: ImageStreamTag
    name: joke-api:${IMAGE_SUFFIX}
```

3. Re-process the template with the `IMAGE_SUFFIX` parameter. `oc process -f openshift/demo-express-server/build-infra.yaml -p IMAGE_SUFFIX=prod -o yaml`

4. Processing a template is not done on Openshift, in order to apply a new template you need to take the output
from an `oc process` and use it in a `oc create` or `oc apply` command. This can be chained together with `|` in bash terminals. `oc process -f openshift/demo-express-server/build-infra.yaml -p IMAGE_SUFFIX=prod -o yaml | oc apply -f - --dry-run`

## Summary

At this stage, there is a working piece of infrastructure code that has been abstracted into a template for
reusability. This is something that you'd want to save as apart of your git history. 

Labels have been applied to allow the grouping of all these Openshift objects in logical ways. The granular `app` label will group instances the BuildConfig and ImageStreams and the more global `project` label will allow you to group all objects that belong to the project.


## Creating the Deployment
The Deployment side of your application is not done. You can bootstrap that using
all you've learned up to this point and the `oc new-app` command. The `oc new-app` is similar to 
`new-build` in that it will attempt to create a __BuildConfig__ and __ImageStream__ for you. In addition,
it will also create a __DeploymentConfig__ and a __Service__. You will need to strip out the __ImageStream__ and __BuildConfig__ from the `new-app` output as you have already dealt with that part of the app lifecycle.

> Reminder to create appropriate labels when running your oc commands! Something like `-l app=joke-api` is helpful

1. Run `new-app` in your __DEV__ namespace and correctly configure the __Service__ target port to __3000__
> Ensure the new-app is pointing to your __TOOLS__ namespace imagestream
2. Expose a route for the app by running `oc expose` so that it is accessible by the internet
3. Check that the API is working correctly by running a HTTP GET request to `/joke` from the route.
> run a curl command or click on the route and navigate to /joke in your browser
4. Get all of your resources that you created and convert it into a template. Remember to use the `--export=true` flag when running `oc get all`
5. Delete your infracode on openshift with `oc delete all -l ...` and re-process and apply your template to ensure it is working correctly. 


## Big Takeaway

When your infrastructure code is set up correctly, your team will have a huge confidence boost that the application will behave as it should. A great way to test that is to __delete__ your infrastructure on openshift
and attempt to recreate it with your templates.