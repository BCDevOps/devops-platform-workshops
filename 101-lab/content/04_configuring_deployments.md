
# Exploring Deployment Options
Additional actions are available to edit your deployment. Review and explore; 
  - Resource Limits
  - Replicas

## Using `oc explain`

`oc explain` is a great utility to discover all the available fields for an
OpenShift of K8s object. 

- Discover the fields that belong to a Deployment
  - `oc explain deployment`
  - check out what is inside the `spec` field
  - `oc explain deployment.spec`
  - From this view you can see that `replicas` are configurable 

## Versioning a Deployment Configuration
At this point in time, your deployment configuration has undergone many changes, such as adding environment variables and adding health checks. 
Review the deployment configuration `ReplicaSet` tab: 
  - Navigate to your Deployment and select `ReplicaSet`
  ![](./images/04_deployment_configuration.png)
  - Select your latest replica set and select `edit`
  - Compare the differences between that replica set and an older one - this can be done through the UI or by comparing the YAML

## Changing the Deployment Strategy Option
The default deployment configuration provides a `Rolling Update` style deployment, which waits for the container to be ready prior to 
cutting over traffic and terminating the previous container. 

  - Change the strategy to a `Recreate` and redeploy a couple of times
  - edit the YAML for the deployment and replace the `spec.strategy.type` from `RollingUpdate` to `Recreate
![](./images/04_deploy_strategy_01.png)
![](./images/04_deploy_strategy_02.png)
  - Now make a small change to the deployment to trigger a new deploy (for testing)
  - `oc -n [-dev] set env deployment/rocketchat-[username] TEST=BAR`
  - Go back to topology and observe the behaviour. You should notice that the old pod is killed before a new one is created.
  - edit the YAML and switch the strategy back to RollingUpdate

Next page - [Resource Management](./05_resource_management.md)
