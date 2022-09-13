
# Exploring Deployment Options
Additional actions are available to edit your deployment. Review and explore:
  - Resource Limits
  - Replicas

## Using `oc explain`

`oc explain` is a great utility to discover all the available fields for an OpenShift or Kubernetes object. 

- Discover the fields that belong to a Deployment
  - `oc explain deployment`
  - Check out what is inside the `spec` field
  - `oc explain deployment.spec`
  - From this view you can see that `replicas` are configurable 

## Versioning a Deployment Configuration
At this point in time, your deployment configuration has undergone many changes, such as adding environment variables and adding health checks. 
Review the deployment configuration `ReplicaSets` tab: 
  - Navigate to your Deployment and select `ReplicaSets`
  ![Rocketchat deployment details screen showing ReplicaSets tabs](./images/04_deployment_configuration.png)
  - Select your latest replica set and select `edit`
  - Compare the differences between that replica set and an older one - this can be done through the UI or by comparing the YAML

## Changing the Deployment Strategy Option
The default deployment configuration provides a `RollingUpdate` style deployment, which waits for the container to be ready prior to cutting over traffic and terminating the previous container.
  - Navigate back to your rocketchat-[username] deployment.
  - From the Actions menu, select "Edit update strategy". Change the strategy to a `Recreate`. Next, redeploy a couple of times by editing your pod count to zero, then increasing to one pod (Actions menu -> Edit Pod count, or update `spec.replicas` in the YAML).
  - Edit the YAML for the deployment and change the `spec.strategy.type` from `RollingUpdate` to `Recreate`. Make sure to remove the `spec.strategy.rollingUpdate` node as in the screenshots below.
![Rocketchat deployment details screen showing YAML tab with RollingUpdate strategy](./images/04_deploy_strategy_01.png)
![Rocketchat deployment details screen showing YAML tab with Recreate strategy](./images/04_deploy_strategy_02.png)
  - Now make a small change to the deployment to trigger a new deploy (for testing):
    - `oc -n [-dev] set env deployment/rocketchat-[username] TEST=BAR`
  - Go back to Topology and observe the behaviour. You should notice that the old pod is killed before a new one is created.
  - Edit the YAML and switch the strategy back to `RollingUpdate`.

Next page - [Resource Management](./05_resource_management.md)
