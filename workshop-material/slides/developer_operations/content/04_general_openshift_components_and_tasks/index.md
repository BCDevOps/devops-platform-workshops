---
# General OpenShift Components / Tasks

Note:
Note Placeholder


---
#### Discussion and Labs
- Project Access Control
- Deployment Styles (to cover a few)
  - Rolling vs. Recreate
  - Blue Green
  - Rollbacks
  - Triggers
- Stateful Sets and Application Clustering
- Application Availability

Note:
Note Placeholder


---
#### Project Access Control
- Team 'admins' are in control of user access to each project
  - Use of default roles should be leveraged
      - Project admin
      - Project editor
      - Project viewer
- Service accounts are used to 
  - permit pulling of images from one namespace to another
  - manage resources across multiple projects from a CI & CD tool (ie. Jenkins)

Note:
Note Placeholder


---
#### Lab/Demo: Access Management (20 minutes)
- DevOps Team Services provisions project set and assigns admin
- Students nominate the first `admin`
  - admin user grants `edit` access to developers in team to projects in project set
  - users confirm access
  - demonstrate/show `rolebindings` resources
[Lab Link]()

---
#### Deployment Styles
- Rolling vs. Recreate
  - Rolling
    - Supports life-cycle hooks for injecting code into deployment process
    - Waits for pods to pass readiness check before scaling down old components
    - Does not allow pods that do not pass readiness check within timeout
    - Used by default if no strategy specified on deployment configuration
 - Recreate
    - Has basic rollout behavior
    - Supports life-cycle hooks for injecting code into deployment process
    - Steps in recreate strategy deployment:
    - Execute pre life-cycle hook
    - Scale down previous deployment to zero
    - Scale up new deployment
    - Execute post life-cycle hook
  - Rollbacks
  - Triggers

Note:
Note Placeholder


---
#### Deployment Styles
- Blue - Green
  - Two versions of an application "blue" and "green"
  - 'Green' version hosts current production application
  - 'Blue' version is the new version
  - OpenShift Route can be configured to split traffic between Green and Blue (by %)
  - After validating new software version, can switch all traffic to new version

Note:
Note Placeholder


---
#### Deployment Styles
- New deployments and rollbacks
  - If not doing blue-green, a the rollout and rollback commands can be used
  - Each modification to a deployment creates a new version of the deployment (and often auto-starts a rollout)
  - Deploying a new version of an app is often as simple as updating the image version tag in the deployment config
    - This can be used to change to any version, new or old, of an image
  - From CLI:   
    - Running `oc rollout latest [deployment config name]` will deploy the latest version
    - Running `oc rollback  [deployment config name]` will roll back to the latest functional version

Note:
Note Placeholder


---
#### Triggers
- Triggers enable automations within the OpenShift platform
- Triggers can be applied to builds and deployments
- Triggers can be be invoked from: 
  - Webhooks
  - Config Changes
  - Image Changes

Note:
Note Placeholder


---
#### Lab: Deployment
- developers create BuildConfigurations in `-tools` project for a sample app (provided)
- developers create DeploymentConfigurationS in `dev` project for the app that is being built; deployments fails due to image pull auth failure
- admin user runs policy command to grant `default` service account in `dev` project `image-puller` role; deployments succeeds
- developers change an environment value to trigger redeployment with default deployment strategy, noticing sequence of changes
- developers change deploymentr strategy and change environment variable to trigger deployment again


---
#### StatefulSets and Application Clustering
- Some applications cannot simply be scaled by increasing pods because they hold state
  - These are referred to as stateful applications
  - Some examples include: elasticsearch, postgres, mysql
- In general, we prefer statless apps over stateful apps
- StatefulSets allow each pod to maintain an individual identity, but provide scalaing capabilities
- StatefulSets should only be used when perscribed by the application; if a stateless app can be deployed, it should be

Note:
Note Placeholder


---
#### Application Availability
- Pods to not 'migrate', but rather stop and restart
- Node evacuations (for maintenance) kill a pod, but do not 'redeploy'
- High Availability requires more than one pod to be active to service requests
- OpenShift will distribute multiple pods across different nodes where possible
- Pod affinity, anti-affinity, and pod disruption budgets can be used in complex scenarios

Note:
Note Placeholder


---
#### Lab/Demonstrate: Application Availability
- developers scale up their applications to more than one replica
- demonstrate autoscaling configuration and trigger with simulated load