---
# Codify your OPS

Note:
(30m) Some interesting ideas about why?


---
#### GitOps

No more critical updates in the GUI forgotten long lost!

- Create *consistently repeatable* OpenShift objects
    - Declarative specifications for your objects
    - Stored with your application, as code in your repository
    - Applied by your pipeline
- Let the GUI visualize your dashboards and environment, while your changes are created and tracked in a PR

Note:
Note Placeholder


---
#### Where do I start?
From right where you are today!

- Deploy your application as you are used to (oc new-build, oc new-app, etc)
- Configure your application with extra objects (secrets, configmaps, routes, etc)
- To export a group of objects:
    ```
    oc get --export all -o yaml > new-objects.yaml
    oc get --export svc,dc,route -l FOO=BAR -o yaml > filtered-objects.yaml
    ```
- To export an individual object manifest file:
    ```
    oc get --export {object/name} -o yaml > new-object-manifest.yaml
    ```

Note:
- Break your project into separate templates by using labels or object types as filters to the `oc get --export` command
- oc "all" is not everything


---
#### Draw your Stuff
Having a whiteboard session to draw out the connected pieces and dependencies can really help in the design.

![](content/02_template_your_deployments/drawing_objects.png)<!-- .element style="border: 0; background: None; box-shadow: None; height: 60%; width: 60%;" -->

Note:
Note Placeholder


---
#### Design your Deployment
Templates vs static object manifests

- Design templates for the re-usable objects (and dependencies)
    - Deployments (DeploymentConfig, StatefulSet)
    - Abstractions (Services, Routes, ServiceAccounts, RoleBindings, etc)
- Design static object manifests for environment specific objects
    - Secrets, ConfigMaps
    - PVCs

Note:
Templates groups objects together and allows you to parameterize the object definitions for ease of re-use.  
One-off object manifests are not ready (or meant) for re-use.


---
##### Labels and Parameters

- Create **meaningful labels** and add them at the template metadata layer to apply to all objects that the template will manage
- Labels can:
  - be used to group objects in your template
  - make cleanup/redeployment easier
  - identify release versions

- Parameters allow the templates to be reusable
  - application name
  - git configuration (git repo, tag, branch?)
  - PVC Names, secret names, configmaps, etc

Note:
Can use a parameter file: --param-file=dev.yaml
Can add additional labels such as git tag for a version?


---
#### Deploy Your Stuff!
Your first deploy doesn't have to wait for any parameters; add them in as the objects are refined through testing

- using `oc apply` you can keep an object definition updated from a yaml or json manifest
- use `oc process` to create the object definitions from a template for `oc apply`
    ```
    oc apply -f my-configmap.yaml
    oc process -f new-template.yaml -p FOO=VAR | oc apply -f -
    ```
- Parameter files can store multiple parameters for a specific environment
    ```
    oc process -f new-template --param-file=myapp-dev.yaml | oc apply -f -
    ```

Note:
Can add additional labels such as git tag for a version?


---
#### Refine and Repeat
- Modify the template file:
    - Add more parameters (with sane defaults)
    - Process and apply your template in your dev namespace
    - Each successive apply will modify or create your objects. (but not delete them)

Note:
Note Placeholder


---
#### Deploy to next environment
![](content/02_template_your_deployments/package_delivery.png)<!-- .element style="border: 0; background: None; box-shadow: None; height: 40%; width: 40%; " -->
- Use the templates and object files to deploy to a second environment
- Verify objects and application are running as expected

Note:
Note Placeholder


---
#### Smells like a Pipeline!
![](content/02_template_your_deployments/lets-go-giffy.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


--- 
#### Helm
- Isn't an OpenShift primative 
- Somewhat overlaps with OpenShift templates
- Is super duper popular, which is why we are talking about it!

![](content/02_template_your_deployments/popular.jpg)<!-- .element style="border: 0; background: None; box-shadow: None; height: 30%; width: 30%" -->

Note:
Note Placeholder


---
### What is Helm?
- Helm is a (well... the official) Package Manager for Kubernetes
  - package multiple K8s resources into a single logical deployment unit: Chart
  - but it's not just a Package Manager
- Helm is a Deployment Manager for Kubernetes to; 
  - perform a repeatable deployment
  - manage dependencies: reuse and share
  - manage multiple configurations
  - update, rollback and test application deployments (Releases)

Note:
Note placeholder


--- 
### Helm Architecture
![](content/02_template_your_deployments/helm_architecture.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Placholder


---
#### OpenShift Templates vs Helm
- OpenShift templates are simple "deployment" tools
  - Requires OpenShift; does NOT work across other kubernetes platforms
- Helm is more of a package manager
  - Requires Tiller for package management
  - We do NOT run Tiller in the OpenShift environment due to the elevated privileges it requires
  - Many kubernetes-native apps are being distributed with Helm charts
- Helm CAN be used to deploy applications (without package management)
  - Helm is used in client-only mode
  - Helm is used in template mode to render the artifacts before applying them
  - This has similar functionality to OpenShift templates 

Note:
Note Placeholder


--- 
### Using Helm Without Tiller

```
helm repo add [chartname] [chart-path]
helm fetch [chartname]/[component]
helm template ./[component].tgz --set \
  key1=value1 \
  key2=value2 \
  | oc apply -f -
```

Note:
Note Placeholder


---
#### Lab: Build Object Manifests

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Build codified object from existing new-app (30)
Create a build config for grafana image (in tools)
convert to an object that can be codified in yaml/json
 - oc get --export=true buildconfig grafana-{user} -o yaml
 - modify object (name, other?)
delete buildconfig
What did we miss? (imagestream? other build artefacts?
create exports for additional object(s):
ImageStream
{Others?}


---
#### Lab: Build Template

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Creating template from codified build objects (build config and imagestream)
using a skeleton template file
 - add initial Metadata
 - parameters (and parameter substitutions) (namespace?)
 - create a parameter file (named for tools environment)
Process and apply from template
oc process -f {template} --param-file={parameterFile} | oc apply -f -
use oc new-app with built image to create initial deploymentconfig
export object(s) as yaml
 - check for deploymentconfig object, Service Objects, etc
build template for deployment config
remove initial application deployment
re-apply using deployment config template.
Create configmap object
add configmap object to application template
configure dc to map configmap to configuration file.
Re-apply template


---
#### Lab: Re-use / Re-deploy

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
NotAdding Additional parameters to support multiple namespaces
Redeploy to validate
redeploy from template to test namespace
