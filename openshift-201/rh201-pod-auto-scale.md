# Autoscaling Pods
## Objectives:

After completing this section, you should be able to create horizontal pod autoscaler (HPA) resources and VPA....


## Horizontal Pod Autoscalers

OpenShift can autoscale a deployment based on current load on the application pods, by means of a HorizontalPodAutoscaler resource type.

A horizontal pod autoscaler (HPA) resource uses performance metrics collected by the OpenShift Metrics subsystem. The Metrics subsystem comes pre-installed in OpenShift 4.

Creates a horizontal pod autoscaler resource that changes the number of replicas on the hello-world-nginx deployment to keep its pods under 80% of their total requested CPU usage.

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

The horizontal pod autoscaler initially has a value of <unknown> in the TARGETS column. It might take up to five minutes before <unknown> changes to display a percentage for current usage.

A persistent value of <unknown> in the TARGETS column might indicate that the deployment does not define resource requests for the metric. The horizontal pod autoscaler will not scale these pods.



You can create an HPA for any Deployment, DeploymentConfig, ReplicaSet, ReplicationController, or StatefulSet object.

the ratio of the current metric utilization with the desired metric utilization, and scales up or down accordingly.

Supported metrics

|Metric | Description | API version|
|---|---|----|
|CPU utilization| Number of CPU cores used. Can be used to calculate a percentage of the pod’s requested CPU.| autoscaling/v1, autoscaling/v2beta2|
|Memory utilization| Amount of memory used. Can be used to calculate a percentage of the pod’s requested memory.| autoscaling/v2beta2|




```
oc get hpa -o yaml

apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  annotations:
  name: hello-world-nginx
spec:
  maxReplicas: 10
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hello-world-nginx
  targetCPUUtilizationPercentage: 80
```


```
oc describe hpa
Name:                                                  hello-world-nginx
Namespace:                                             ad204f-dev
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Wed, 06 Apr 2022 11:31:44 -0700
Reference:                                             Deployment/hello-world-nginx
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  434% (43m) / 80%
Min replicas:                                          1
Max replicas:                                          10
Deployment pods:                                       10 current / 10 desired
Conditions:
  Type            Status  Reason            Message
  ----            ------  ------            -------
  AbleToScale     True    ReadyForNewScale  recommended size matches current size
  ScalingActive   True    ValidMetricFound  the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  True    TooManyReplicas   the desired replica count is more than the maximum replica count
Events:
  Type    Reason             Age                   From                       Message
  ----    ------             ----                  ----                       -------
  Normal  SuccessfulRescale  104m (x2 over 4d23h)  horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  103m (x2 over 4d23h)  horizontal-pod-autoscaler  New size: 8; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  103m                  horizontal-pod-autoscaler  New size: 9; reason:
  Normal  SuccessfulRescale  99m                   horizontal-pod-autoscaler  New size: 10; reason: cpu resource utilization (percentage of request) above target
```

There are a few more advanced options with the HPAs like scaleup and scaledown policies. Check the online documentation for these details.

https://docs.openshift.com/container-platform/4.10/nodes/pods/nodes-pods-autoscaling.html


## Vertical Pod Autoscaler

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

## Pod Disruption Budgets