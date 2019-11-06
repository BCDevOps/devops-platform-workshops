---
# General OpenShift Components / Tasks

Note:
Note Placeholder


---
#### Discussion and Labs 
- Zero Trust Networking
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


#### Zero-Trust Network Model
- All projects are created with zero network access
- Project teams need to put thought into the network flow of their applications
- 3 basic network security policies can be used as a starting point
- More restrictive policy creation is encouraged
  
Note:
Note Placeholder


---
#### Zero-Trust Networking: Thinking About Traffic Flow
- Default / QuickStart Policies

| Name                       | Description                                                               |
|----------------------------|---------------------------------------------------------------------------|
| egress-internet            | Allow Pods to communicate with the Internet.                              |
| int-cluster-k8s-api-permit | Allow Pods to communicate to the k8s API; this is needed for deployments. |
| intra-namespace-comms      | Allow Pods to communicate amongst themselves within a namespace.          |
|  |  |

- **Important considerations with policy creation**
  - Identifying the `source` and `destination` objects
  - Understanding `egress` and `ingress` flows
  
Note:
Note Placeholder


---
#### Zero-Trust Networking: Creating Network Security Policies
- Tools for creating NetworkSecurityPolicy objects: 
  - Using the `oc` commandline tool
  - Inserting `yaml` into the OpenShift Web Console
  - Within your deployment pipeline
- What's happening? 
  - An ansible-based operator is reading your policy configuration
  - The operator maps that configuration to an Aporeto based network policy
  - The operator creates / updates / or deletes the policy from the Aporeto control plane

Note:
Note Placeholder


---
#### NetworkSecurityPolicy: Architecture Overview
<img src="content/04_general_openshift_components_and_tasks/bcgov-aporeto-high-level.png" height= "80%" width="80%">

Note: 
Note placeholder


---
#### Zero-Trust Networking: Developer Resources
- [developer.gov.bc.ca](http://developer.gov.bc.ca)
  - [NetworkSecurityPolicy: Zero Trust Model Landing Page](https://developer.gov.bc.ca/NetworkSecurityPolicy:-Zero-Trust-Security-Model-on-the-Platform:-Trust-No-One)
  - [NetworkSecurityPolicy: QuickStart](https://developer.gov.bc.ca/NetworkSecurityPolicy:-Quick-Start)
  - [NetworkSecurityPolicy: Custom Policies](https://developer.gov.bc.ca/NetworkSecurityPolicy:-Custom-Policy-Development)

Note:
Note Placeholder


---
#### Demo / Lab
As a group, review the NetworkSecurityPolicy lab and create the 3 basic policies

![](content/04_general_openshift_components_and_tasks/enhance.gif)

Note:
Note Placeholder


---
#### Project Access Control
- Team 'admins' are in control of user access to each project
  - Use of default roles should be leveraged
      - Project admin
      - Project edit
      - Project view
- Service accounts are used to 
  - permit pulling of images from one namespace to another
  - manage resources across multiple projects from a CI & CD tool (ie. Jenkins)

Note:
Note Placeholder


---
#### Lab/Demo: Access Management
- DevOps Team Services provisions project set and assigns admin
- Students nominate the first `admin`
  - admin user grants `edit` access to developers in team to projects in project set
  - users confirm access
  - demonstrate/show `rolebindings` resources


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
  - If not doing blue-green, a rollout and rollback commands can be used
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
- Pods do not 'migrate', but rather stop and restart
- Node evacuations (for maintenance) kill a pod, but do not 'redeploy'
- High Availability requires more than one pod to be active to service requests
- OpenShift will distribute multiple pods across different nodes where possible
- Pod affinity, anti-affinity, and pod disruption budgets can be used in complex scenarios

Note:
Note Placeholder


---
#### Lab Time

Lab 1 - Builds

Lab 2 - Registry Console

Lab 3 - Deployments

Lab 4 - Application Availability

Lab 5 - Autoscaling