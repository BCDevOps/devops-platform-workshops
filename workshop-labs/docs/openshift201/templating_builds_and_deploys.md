## Templating Custom Applications

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

> Applying the `--name=` flag with `oc new-build` automatically created a label `build=joke-api`. This label,
plus other labels that you will want to apply will make it easy to query and modify your infrastructure objects later. 

Run `oc get all -l build=joke-api -o yaml > openshift/demo-express-server/build-infra.yaml` to extract a __stdout__ version  of your infrastructure code and write it to a file. 

> As a bcgov best practice we recommend storing your infrastructure code as `YAML` format. It is easy to read, and allows you to add comments to the code.

> `oc get all` does not get __all__ openshift objects. Some objects that are __not__ queried include: pvcs,
configmaps, secrets, rolebindings

7. Explore the build infrastructure code. 

## We Done Yet? 

Nope! This is far from being ready to be consumed by a pipeline.

## Clearing up the Garbage

When you ran `oc get all -l build=joke-api` it grabbed an __Imagestream__, the __BuildConfig__, and all __Build__ objects. __Build__ objects are created __from BuildConfigs__, for this reason they should be not included as apart of your infra code.

Delete the __Build__ object from the `build-infra.yaml` file.
> you could also run `oc get buildconfig,imagestream -l build=joke-api > openshift/demo-express-server/build-infra.yaml` instead :D


In addition to grabbing Objects that __are not needed as apart of infra code__. There are annotations that
__k8s__ applies to objects that are not needed as code. Things like `metadata.selfLink`, `metadata.creationTimestamp`, `metadata.uid` are not needed. Delete those from the __ImageStream__ and __BuildConfig__ objects.

You can also delete `ImageStream.status` as well. 

## Improving the BuildConfig

The build config is missing a few __BC Gov__ best practices.

1. Add resource request/limits to the build config.

Your tools namespace has a set amount of quota. At this time it is __8 cores__ of cpu and __32 Gb__ of memory. 
Adding requests/limits to a build config will allow you to effectively manage your quota.

Run the command `oc explain buildconfig` to understand what configuration fields are available for them. To drill
further down into nested fields you can __chain__ on terms to the original command. `oc explain buildconfig.spec`.

Investigate where to add resources/requests (`oc explain bc.spec.resources`)

Add these resources to the build config under `spec`

```yaml
resources:
  requests:
    cpu: 100m
    memory: 20Mb
  limits:
    cpu: 150m
    memory: 30Mb
```

2. Delete all objects related to the build and try the build again
`oc delete all -l build=joke-api` and `oc apply -f openshift/demo-express-server/build-infra.yaml`