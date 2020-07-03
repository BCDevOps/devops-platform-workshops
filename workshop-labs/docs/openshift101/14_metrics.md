# Openshift 4 Metrics
> this feature is in tech preview. This means that it is operational but is not supported under any commercial Service Level Agreement 

Openshift 4 provides a more indepth way to surface metrics for your workloads. These metrics are queries using `PromQL`. 

## Running a Sample Metric Query

- Navigate to your __dev namespace__ and select `Advanced -> Metrics`
- Select `Insert Example Query` and observe the cpu utilization of your pods


A Pod can be extended beyond the normal operation of the container by allowing developers to: 
- add `init` containers
- add `pre` and `post` lifecycle hooks
- modify the default `entrypoint` of a container

## Init Containers
Init containers are best used to prepare the pod for normal operation. In this lab, you will add a simple init container that posts a message to rocketchat with your pod hostname.

- From the Web Console, navigate to `Applications -> Deployments` and select your `rocketchat-[username]` deploymentconfig
    - If you wish to perform this from the cli with the `oc` tool, type `oc edit dc/rocketchat-[username]`
- Select `Actions -> Edit YAML`

![](../assets/12_pod_lifecycle_01.png)

- Add the following section of code under `spec: -> template: -> spec:`

```
      initContainers:
      - name: init
        image: giantswarm/tiny-tools
        command: ["/bin/sh", "-c", "c=$(curl -X POST -H 'Content-Type: application/json' --data '{\"text\":\"Say Hello\"}' https://chat.pathfinder.gov.bc.ca/hooks/xxx/xxx)"]
```

- Select Save
- Ask the instructor to ensure the rocketchat instance is displayed to the class
- Explore the `Pod Details` to notice the differente with the Init Container 

![](../assets/12_pod_lifecycle_02.png)

In order to obtain logs from the init container, the `oc` command can be used by specifying `-c init`: 

```
oc logs rocketchat-[username]-[pod-id] -c init
```

## Lifecycle Hooks
Lifecycle hooks can be configured to start and stop a container properly. The lifecycle hook is tied directly to each container. Add a similar pre and post hook as the `initContainer` to demonstrate when it executes in your rocketchat deployment. 

- From the Web Console, navigate to `Applications -> Deployments` and select your `rocketchat-[username]` deploymentconfig
    - If you wish to perform this from the cli with the `oc` tool, type `oc edit dc/rocketchat-[username]`
- Select `Actions -> Edit YAML`

- Add the following section of code under `spec: -> template: -> spec: -> containers`

```
          lifecycle:
            postStart:
              exec:
                command:  ["/bin/sh", "-c", "c=$(curl -X POST -H 'Content-Type: application/json' --data '{\"text\": \"'\"$HOSTNAME\"' is at the postStart phase, huzzah! \"}' https://chat.pathfinder.gov.bc.ca/hooks/xxx/xxx)"]
            preStop:
              exec:
                command:  ["/bin/sh", "-c", "c=$(curl -X POST -H 'Content-Type: application/json' --data '{\"text\": \"'\"$HOSTNAME\"' is just about to STOPPPPPP! \"}' https://chat.pathfinder.gov.bc.ca/hooks/xxx/xxx)"]
```

- Select Save
- Ask the instructor to ensure the rocketchat instance is displayed to the class



## Overriding the Entrypoint 
It may be necessary, from time to time, to override the intitial command/entrypoint of a container image. Generally this is used for troubleshooting purposes, or to override a vendor provided image. 

## Why Metrics are Important

Metrics provide some great insights into how your pods are behaving. Are they being worked too hard (is the cpu utilization high for the amount they are requesting?). Are pods consistently failing at certain times (can they handle spikes in traffic?). 

It is recommended to keep an eye on your metrics. This is a great way to refine your cpu and memory utilization requests within your deployment configs. Over time you will get an accurate picture of how much resources are actually consumed and can [adjust the resource usage](https://developer.gov.bc.ca/Resource-Tuning-Recommendations) accordingly within the `DeploymentConfig` or `StatefulSet` of an application. 

## References
https://docs.openshift.com/container-platform/4.3/monitoring/cluster_monitoring/examining-cluster-metrics.html#examining-cluster-metrics

