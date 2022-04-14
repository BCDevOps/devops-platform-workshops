# Autoscaling Pods
## Objectives

After completing this section you should have a better understanding of Horizontal Pod Autoscalers (HPA), Vertical Pod Autoscalers (VPA), and Pod Disruption Budgets (PDB). And go through the steps to configure and observe these resources.

## Horizontal Pod Autoscalers

OpenShift can autoscale a deployment based on current load on the application pods, by means of a HorizontalPodAutoscaler resource type.

A horizontal pod autoscaler (HPA) resource uses performance metrics collected by the OpenShift Metrics subsystem. The Metrics subsystem comes pre-installed in OpenShift 4.

You can also create an HPA for DeploymentConfig, ReplicaSet, ReplicationController, or StatefulSet objects.

This command will create a horizontal pod autoscaler resource that changes the number of replicas on the hello-world-nginx deployment to keep its pods under 80% of their total requested CPU usage.

```
oc autoscale deployment/hello-world-nginx --min 1 --max 5 --cpu-percent 80
```

The maximum and minimum values for the horizontal pod autoscaler resource serve to accommodate bursts of load and avoid overloading the OpenShift cluster. If the load on the application changes too quickly, then it might be advisable to keep a number of spare pods to cope with sudden bursts of user requests. Conversely, too many pods can use up all cluster capacity and impact other applications sharing the same OpenShift cluster.

Edit the load-test deployment requests environment variable which will re-trigger the deployment to start a load-test pod that will send traffic to the hello-world-nginx pod. You should see the number of pods increase as the CPU metrics grow.

To get information about horizontal pod autoscaler resources in the current project, use the oc get command.

```
oc get hpa 
NAME                REFERENCE                      TARGETS    MINPODS   MAXPODS   REPLICAS
hello-world-nginx   Deployment/hello-world-nginx   600%/80%   1         10        4        
```

The horizontal pod autoscaler initially has a value of `<unknown>` in the TARGETS column. It might take up to five minutes before <unknown> changes to display a percentage for current usage.

A persistent value of `<unknown>` in the TARGETS column might indicate that the deployment does not define resource requests for the metric. The horizontal pod autoscaler will not scale these pods.

### API Versions 

There are different API versions for autoscaling v1 just works with CPU metrics. The v2beta2 API handles more options and metrics including cpu and memory.

|Metric | Description | API version|
|---|---|----|
|CPU utilization| Number of CPU cores used. Can be used to calculate a percentage of the pod’s requested CPU.| autoscaling/v1, autoscaling/v2beta2|
|Memory utilization| Amount of memory used. Can be used to calculate a percentage of the pod’s requested memory.| autoscaling/v2beta2|

You can check the autoscaling API versions available in the cluster.

```
oc api-versions | grep autoscaling
```

The `oc autoscale` command will create a v1 type autoscaler. You can view with the hpa details with an `oc get hpa` command.

```
oc get hpa -o yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: hello-world-nginx
spec:
  maxReplicas: 5
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hello-world-nginx
  targetCPUUtilizationPercentage: 80
```

To create a v2beta2 autoscaler you need to define in a yaml.

```
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: hello-world-nginx-mem-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hello-world-nginx
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: AverageValue
        averageValue: 30Mi
```

Under metrics you can set type to AverageValue and specify averageValue memory.

You can also specify Utilization in the metrics section of the v2beta2 HPA.

```
metrics: 
  - type: Deployment
    resource:
      name: memory 
      target:
        type: Utilization 
        averageUtilization: 50 
```

Specify averageUtilization and a target average memory utilization over all the pods, represented as a percent of requested memory. The target pods must have memory requests configured.

### Memory HPA

For memory-based autoscaling, memory usage must increase and decrease proportionally to the replica count. On average an increase in replica count must lead to an overall decrease in memory (working set) usage per-pod. A decrease in replica count must lead to an overall increase in per-pod memory usage.

Apply the `hello-world-nginx-mem-hpa` from above to your project. Trigger a re-deploy of the load-test deployment.

Describe the HPA.

```
oc describe hpa hello-world-nginx-mem-hpa
Name:                       hello-world-nginx-mem-hpa
Namespace:                  ad204f-dev
Reference:                  Deployment/hello-world-nginx
Metrics:                    ( current / target )
  resource memory on pods:  44965888 / 30Mi
Min replicas:               1
Max replicas:               5
Deployment pods:            2 current / 2 desired
Conditions:
  Type            Status  Reason              Message
  ----            ------  ------              -------
  AbleToScale     True    ReadyForNewScale    recommended size matches current size
  ScalingActive   True    ValidMetricFound    the HPA was able to successfully calculate a replica count from memory resource
  ScalingLimited  False   DesiredWithinRange  the desired count is within the acceptable range
Events:
  Type    Reason             Age                 From                       Message
  ----    ------             ----                ----                       -------
  Normal  SuccessfulRescale  71m                 horizontal-pod-autoscaler  New size: 3; reason: All metrics below target
  Normal  SuccessfulRescale  65m (x12 over 70m)  horizontal-pod-autoscaler  New size: 2; reason: All metrics below target
```

**Note:**
All pods must have resource requests configured

The HPA makes a scaling decision based on the observed CPU or memory utilization values of pods in an OpenShift Container Platform cluster. Utilization values are calculated as a percentage of the resource requests of each pod. Missing resource request values can affect the optimal performance of the HPA

### Advanced Options

There are a few more advanced options with the HPAs like scaleup and scaledown policies. Check the online documentation for these details.

* https://docs.openshift.com/container-platform/4.10/nodes/pods/nodes-pods-autoscaling.html
* https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/


## Vertical Pod Autoscaler


reviews the historic and current CPU and memory resources for containers in pods and can update the resource limits and requests based on the usage values it learns

update all of the pods associated with a workload object, such as a Deployment, DeploymentConfig, StatefulSet, Job, DaemonSet, ReplicaSet, or ReplicationController, in a project.

The Vertical Pod Autoscaler Operator (VPA) is implemented as an API resource and a custom resource (CR). The CR determines the actions the Vertical Pod Autoscaler Operator should take with the pods associated with a specific workload object, such as a daemon set, replication controller, and so forth, in a project.

```
oc api-resources | grep vpa
```


To use the VPA to automatically update pods, create a VPA CR for a specific workload object with updateMode set to Auto or Recreate.

To use the VPA to only determine the recommended CPU and memory values, create a VPA CR for a specific workload object with updateMode set to off.

**Work in Progess**

```
apiVersion: autoscaling.openshift.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: default
  namespace: openshift-vertical-pod-autoscaler
spec:
  minReplicas: 3 
  podMinCPUMillicores: 25
  podMinMemoryMb: 250
  recommendationOnly: false
  safetyMarginFraction: 0.15
```


```
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: vpa-recommender
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment 
    name:       hello-world-nginx
  updatePolicy:
    updateMode: "Auto" 
```

VPA won't work with HPA using the same CPU and memory metrics because it would cause a race condition


VPA is not aware of Kubernetes cluster infrastructure variables such as node size in terms of memory and CPU. Therefore, it doesn't know whether a recommended pod size will fit your node. 

Whenever VPA updates the pod resources the pod is recreated, which causes all running containers to be restarted. The pod may be recreated on a different node.


* https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler
* https://docs.openshift.com/container-platform/4.10/nodes/pods/nodes-pods-vertical-autoscaler.html
## Pod Disruption Budgets

**Work in Progess**