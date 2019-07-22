---
# CI/CD and Pipeline Basics

Note:
Note Placeholder


---
#### CI/CD
- Continuous Integration
    - the developer's working copies are synchronized with a shared mainline several times a day
- Continuous Delivery
    - the logical evolution of continuous integration: Always be able to put a product into production
- Continuous Deployment 
    - automatically deploy the product into production whenever it passes QA

Note:
Note Placeholder


---
#### OpenShift Internal CI/CD Capabilities
- Webhook triggers for builds
    - Build my application image when my code changes
- ImageChangeTriggers for builds
    - Build my application image when my base image changes
- Post-build test hooks
    - Test my application image before I push it to a registry
- ImageChangeTriggers for deployments
    - Redeploy my application when my image changes (e.g. after a build)

Note:
Note Placeholder


---
#### OpenShift External CI/CD Capabilities
- API calls from external CI/CD system
    - Trigger a build
    - Trigger a deployment
    - Tag an image between registries
- Via oc client or direct API invocations

Note:
Note Placeholder


---
#### Jenkins Introduction
- The defacto CI/CD tool provided by Red Hat in OpenShift
- Provides flexible capabilties that are integrated into OpenShift
- Multiple catalog items exist
![](content/04_intro_to_pipelines/catalog_jenkins.png)

Note:
Note Placeholder


---
#### Persistent vs. Ephemeral Instances
- Persistent Jenkins masters are the most common deployment
- Often slower than ephemeral instances, however: 
  - Custom configuration is maintained across pod restarts
  - Build history is maintained
- Ephemeral instances lose all configuration  / history upon restart of a pod

Note:
Note Placeholder


---
#### Jenkins Pipelines - Promotion across environments
![](content/04_intro_to_pipelines/cicd.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


---
#### Jenkins Pipelines - Promotion across environments
- Jenkins should only run in the `tools` project
  - Service accounts are provided access to `dev`, `test`, and `prod` projects
  - Each project service accounts group is provided `system:image-puller` role with permission to pull from the tools project
  - Image tagging should be used diligently to ensure the right images are depoyed to the appropriate namespaces

Note:
Note Placeholder


---
#### Jenkins OpenShift Integration
- OpenShift Jenkins Integration Documentation
    - https://docs.openshift.com/container-platform/3.11/dev_guide/openshift_pipeline.html#openshift-jenkins-Pipeline-plugin
- OpenShift Client Plugin
    - https://github.com/openshift/jenkins-client-plugin
    - OpenShift API interaction with a pipeline DSL
    - oc client integration
- OpenShift Pipeline Plugin / Build Strategy

Note:
Note Placeholder


---
#### OpenShift Pipelines
- OpenShift and Jenkins together: 
    - Integrated Jenkins master and slave images
    - Synchronization logic between Jenkins and OpenShift
    - Web console for viewing Pipelines
    - Autoprovisioning of Jenkins as needed via Jenkinsfile detection
    - Pipeline BuildConfig strategy type
        - Treat a Pipeline like any other OpenShift build
            - `oc start-build`
            - `oc get builds`
        - Appears in web console
        - Build status reflects pipeline success
        - Supports all typical build triggers
        - Has no builder image, no output
        - Cannot use oc logs (there is no pod)

Note:
Jenkins basic pipeline has several assumptions.


---
#### Jenkins Plugin DSL & the Jenkinsfile
- Groovy syntax used in the Jenkinsfile
- Jenkinsfile can be included in the BuildConfig object, or alongside the application code
- Types of OpenShift actions supported:
  - Builds - trigger, watch, verify
  - Deployments - trigger, scale, verify
  - Services - verify availability
  - Images - tag
  - Resources - create from yaml/json, delete by name, label, or yaml/json
- https://jenkins.io/doc/pipeline/steps/openshift-pipeline/

Note:
Jenkins basic pipeline has several assumptions.


---
#### Pipeline Sample Configuration
![](content/04_intro_to_pipelines/sample_pipeline.png)

Note:
Note Placeholder


---
#### Jenkins Images
- Jenkins Master Image
    - OpenShift Pipeline plugin, Jenkins Pipeline plugin
    - Kubernetes plugin for slave pod launching
    - oc client, git client tools for shell operations
    - Sync plugin for synchronizing pipeline state
    - Self-configures slave templates
- Jenkins Slave Images
    - Maven, NodeJS
    - Include oc, git, framework specific tools
    - Auto-instantiated in pods via Kubernetes slave pod plugin
    - Connects back to jenkins master via service definition environment

Note:
Note Placeholder


---
#### Jenkins Agent Images
- Custom agents can easily be used to extend the build capabilities
- Through the GUI, this can be done in the Jenkins configuration:
![](content/04_intro_to_pipelines/sample_agent_configuration_gui.png)

Note:
Note Placeholder


---
#### Jenkins Agent Images
- Or in your jenkinsfile: 
![](content/04_intro_to_pipelines/sample_agent_configuration_jenkinsfile.png)

Note:
Note Placeholder


---
#### Jenkins Auto Provisioning
- The auto-provisioned Jenkins instance creates: 
    - Route
    - Service
    - Deployment Config
    - Oauth credentials
    - Service Account
    - Edit permission binding
    - Persistent storage

- Users that want to customize the Jenkins deployment (ie. different route name, ephemeral storage, etc) can manually deploy the instance from the Catalog
- Autoprovisioning will not occur if an existing Jenkins instance exists

Note:
Note Placholder


---
#### Jenkins Pipelines - Extending Jenkins with Plugins
- Add additional plugins that may not be included in the base image
- Avoid manual installation by setting the INSTALL_PLUGINS environment variable
- Manual install / configuration requires persistent storage

Note:
Note Placeholder


---
#### Jenkins Opinionated Best Practices
- Instance configuration
    - Leverage ephemeral if possible
    - Avoid complex manual configuration if possible
    - Attempt to treat this as cattle, not a pet
    - If persistent, keep your plugins and components upgraded
- Permission structures
    - Only the Jenkins service account has access to deploy to prod (regular users do not)
- Jenkinsfile
    - stored with code (not in BuildConfig)
    - contains as much as possible to reduce manual configuration

Note:
Note Placeholder


---
#### Lab: Jenkins Basic Pipeline

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Talk through assumptions this pipeline makes (ie: that a deployment already exists and will be triggered with the new build of an image)


---
#### Lab: Jenkins More Advanced PIpeline

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
placeholder


---
#### Lab: OpenShift Objects in Jenkins Pipelines

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
placeholder

