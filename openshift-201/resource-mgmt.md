# Limiting Resource Usage by an Application

## Objectives:

After completing this section, you should be able to limit the resources consumed by containers, pods, and projects. 

## Defining Resource Requests and Limits for Pods. 

A pod definition can include both resource requests and resource limits:

**Resource requests:**
* Used for scheduling and to indicate that a pod cannot run with less than the specified amount of compute resources. The scheduler tries to find a node with sufficient compute resources to satisfy the pod requests. 

* If a node’s memory is exhausted, OpenShift Container Platform prioritizes evicting its containers whose memory usage most exceeds their memory request. In serious cases of memory exhaustion, the node OOM killer may select and kill a process in a container based on a similar metric.

**Resource limits:**
* Used to prevent a pod from using up all compute resources from a node. The node that runs a pod configures the Linux kernel cgroups feature to enforce the pod's resource limits.

* If the memory allocated by all of the processes in a container exceeds the memory limit, the node Out of Memory (OOM) killer will immediately select and kill a process in the container.

Resource request and resource limits should be defined for each container in either a Deployment, DeploymentConfiguration, StatefulSets, BuildConfigs, and CronJob. If requests and limits have not been defined, then you will find a resources: {} line for each container.

Lets create a deployment to test! Create this deployment in your project.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      deployment: hello-world-nginx
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      annotations:
      labels:
        deployment: hello-world-nginx
    spec:
      containers:
      - image: quay.io/redhattraining/hello-world-nginx:v1.0
        name: hello-world-nginx
        resources:
          requests:
            cpu: "10m"
            memory: 20Mi
          limits:
            cpu: "80m"
            memory: 100Mi
        ports:
        - containerPort: 8080
          protocol: TCP
```

You can use the oc edit command to modify a deployment or a deployment configuration, to ensure you use the correct indentation. Indentation mistakes can result in the editor refusing to save changes. To avoid indentation issues, you can use the oc set resources command to specify resource requests and limits. 

Lets modify our deployment using the following command:

```
[user@host ~]$ oc set resources deployment hello-world-nginx --requests cpu=15m,memory=25Mi --limits cpu=100m,memory=150Mi
```

This will cause the pod to re-deploy with updated resources.

If a resource quota applies to a resource request, then the pod should define a resource request. If a resource quota applies to a resource limit, then the pod 
should also define a resource limit. We recommend defining resource requests and limits always.

## Generate traffic and observe 

Let's expose our deployment from above with a service and a route.

* Expose the deployment with a service, the easiest way would be: `oc expose deployment/hello-world-nginx`
* Create an secure route with edge TLS termination from this service. This can be done from the web console or CLI.

Now that our Nginx web server has a route we can access, we can generate some traffic to it and see how our requests and limits settings work.

Create a new deployment. This will deploy an httpd container and use the ab (apache benchmark) command to generate traffic to a URL and then print a summary. Then the pod will stop. If you update the environment variables for the deployment that will trigger a pod redeployment to run the test again. Update the deployment below with the url to your Nginx web server under the SERVICE_HOST variable.

```
kind: Deployment
apiVersion: apps/v1
metadata:
  name: load-test
  namespace: lab2
  labels:
    app: load-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: load-test
  template:
    metadata:
      annotations:
      labels:
        app: load-test
    spec:
      containers:
        - name: load-test
          image: registry.access.redhat.com/rhscl/httpd-24-rhel7
          env:
          - name: SERVICE_HOST
            value: "hello-world-lab1.apps.ocp4.example.com"
          - name: SERVICE_PORT
            value: "443"
          - name: REQUESTS
            value: "5000000"
          - name: CONCURRENCY
            value: "20"
          command: ["/opt/rh/httpd24/root/usr/bin/ab"]
          args: ["-dSrk", "-c $(CONCURRENCY)", "-n $(REQUESTS)", "https://$(SERVICE_HOST):$(SERVICE_PORT)/index.html"]
  
```

From the web console if you change to developer view and navigate to the observe tab select the pod dashboard and your nginx pod. You should see the load-test pod traffic increasing metrics for our pod.

![cpu load](images/resource-mgmt/pod-load-cpu.png)

We can see the traffic we are sending our pod is affecting the cpu quite a bit. In this example we can see the actual cpu usage is over 700% the request we set and  over 100% of the limit we set.

![cpu quota](images/resource-mgmt/pod-load-cpu-quota.png)

Because the actual cpu usage is higher than our cpu limit openshift/kubernetes will throttle the available cpu to our pod. This would affecting the performance of our web server and cause response times of our application.

![cpu throttle](images/resource-mgmt/pod-load-cpu-throttle.png)

We can see this load test isn't affecting the memory much on this pod and our values are probably set correct for this type of load and application running in the pod.

![mem load](images/resource-mgmt/pod-load-mem.png)


## Understanding overcommitment and quality of service classes

A node is overcommitted when it has a pod scheduled that makes no request, or when the sum of limits across all pods on that node exceeds available machine capacity.

In an overcommitted environment, it is possible that the pods on the node will attempt to use more compute resource than is available at any given point in time. When this occurs, the node must give priority to one pod over another. The facility used to make this decision is referred to as a Quality of Service (QoS) Class.

For each compute resource, a container is divided into one of three QoS classes with decreasing order of priority:


|Priority |Class Name |Description|
|---|---|---|
|1 (highest) |*Guaranteed* |If limits and optionally requests are set (not equal to 0) for all resources and they are equal, then the container is classified as *Guaranteed*.|
|2|*Burstable* |If requests and optionally limits are set (not equal to 0) for all resources, and they are not equal, then the container is classified as *Burstable*.|
|3 (lowest)|*BestEffort*|If requests and limits are not set for any of the resources, then the container is classified as *BestEffort*.|


Memory is an incompressible resource, so in low memory situations, containers that have the lowest priority are terminated first:

* Guaranteed containers are considered top priority, and are guaranteed to only be terminated if they exceed their limits, or if the system is under memory pressure and there are no lower priority containers that can be evicted.

* Burstable containers under system memory pressure are more likely to be terminated once they exceed their requests and no other BestEffort containers exist.

* BestEffort containers are treated with the lowest priority. Processes in these containers are first to be terminated if the system runs out of memory.


Do a `oc describe pod <podname>` and see what the value of `QoS Class:` is. Try setting the limits and requests to the same value for the hello world nginx deployment. Once the pod re-deploys check the QoS Class value again.

## Understanding eviction process

When a node in a OpenShift cluster is running out of memory or disk, it activates a flag signaling that it is under pressure. This blocks any new allocation in the node and starts the eviction process.

At that moment, kubelet starts to reclaim resources, killing containers and declaring pods as failed until the resource usage is under the eviction threshold again.

First, kubelet tries to free node resources, especially disk, by deleting dead pods and its containers, and then unused images. If this isn’t enough, kubelet starts to evict end-user pods in the following order:

* Best Effort.
* Burstable pods using more resources than its request of the starved resource.
* Burstable pods using less resources than its request of the starved resource.

You can see some messages like these if one of your pods is evicted by memory use:

```
NAME       READY   STATUS    RESTARTS   AGE
frontend   0/2     Evicted   0          10s
```

## Managing application cpu/memory strategy

The steps for sizing application cpu/memory on OpenShift Container Platform are as follows:

1. Determine expected container cpu/memory usage

Determine expected mean and peak container cpu/memory usage, empirically if necessary (for example, by separate load testing). Remember to consider all the processes that may potentially run in parallel in the container: for example, does the main application spawn any ancillary scripts?

2. Determine risk appetite

Determine risk appetite for eviction or throttling. If the risk appetite is low, the container should request cpu/memory according to the expected peak usage plus a percentage safety margin. Protect your critical pods setting values so they are classified as Guaranteed. If the risk appetite is higher, it may be more appropriate to request cpu/memory according to the expected mean usage.

3. Set container cpu/memory request

Set container cpu/memory request based on the above. The more accurately the request represents the application cpu/memory usage, the better. If the request is too high, cluster and quota usage will be inefficient. If the request is too low, the chances of application eviction increase.

4. Set container cpu/memory limit.

Setting a limit has the effect of immediately killing a container process or cpu throttling if the combined cpu or memory usage of all processes in the container exceeds the limit, and is therefore a mixed blessing. On the one hand, it may make unanticipated excess cpu/memory usage obvious early ("fail fast"); on the other hand it also terminates processes abruptly.

Limits should not be set to less than the expected peak container cpu/memory usage plus a percentage safety margin.

5. Ensure application is tuned

Ensure application is tuned with respect to configured request and limit values, if appropriate. This step is particularly relevant to applications which pool memory, such as the JVM. 

Try adjusting the limits and requests on our web server pod and running the load test again. Observe the results in the openshift dashboards and confirm the pod is not getting throttled. You can consult the ab program details as well - https://httpd.apache.org/docs/2.4/programs/ab.html and set the values to something your app/web server would be expecting at peak usage.

## Viewing Requests, Limits, and Actual Usage

Using the OpenShift command-line interface, you can view compute usage information on individual nodes. The oc describe node command displays detailed information about a node, including information about the pods running on the node. For each pod, it shows CPU requests and limits, as well as memory requests and limits. If a request or limit has not been specified, then the pod will show a 0 for that column. A summary of all resource requests and limits is also displayed.

```
[user@host ~]$ oc describe node node1.us-west-1.compute.internal
Name:               node1.us-west-1.compute.internal
Roles:              worker
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=m4.xlarge
                    beta.kubernetes.io/os=linux
...output omitted...
Non-terminated Pods:                      (20 in total)
...  Name                CPU Requests  ...  Memory Requests  Memory Limits  AGE
...  ----                ------------  ...  ---------------  -------------  ---
...  tuned-vdwt4         10m (0%)      ...  50Mi (0%)        0 (0%)         8d
...  dns-default-2rpwf   110m (3%)     ...  70Mi (0%)        512Mi (3%)     8d
...  node-ca-6xwmn       10m (0%)      ...  10Mi (0%)        0 (0%)         8d
...output omitted...
  Resource                    Requests     Limits
  --------                    --------     ------
  cpu                         600m (17%)   0 (0%)
  memory                      1506Mi (9%)  512Mi (3%)
...output omitted...
```

Note:
The summary columns for Requests and Limits display the sum totals of defined requests and limits. In the preceding output, only 1 of the 20 pods running on the node defined a memory limit, and that limit was 512Mi.

The oc describe node command displays requests and limits, and the oc adm top pods command shows actual usage. For example, if a pod requests 10m of CPU, then the scheduler will ensure that it places the pod on a node with available capacity. Although the pod requested 10m of CPU, it might use more or less than this value, unless it is also constrained by a CPU limit. Similarly, a pod that does not specify resource requests will still use some amount of resources. The oc adm top nodes command shows actual usage for one or more nodes in the cluster, and the oc adm top pods command shows actual usage for each pod in a project.

```
[user@host ~]$ oc adm top pods
NAME                                 CPU(cores)   MEMORY(bytes)   
hello-world-nginx-5d7dc57bdd-jngx5   98m          17Mi            
stress-test-fb76cfbb-pf7ch           32m          25Mi        
```

## Limit Ranges

**to update**
The project registry creates a limit-range for all projects that users can’t delete.

spec:
  limits:
  - default:
      cpu: 250m
      memory: 1Gi
    defaultRequest:
      cpu: 50m
      memory: 256Mi
    type: Container

maybe we can focus on what that limit range does? Also maybe don’t tell teams they can delete it?

A LimitRange resource, also called a limit, defines the default, minimum, and maximum values for compute resource requests, and the limits for a single pod or container defined inside the project. A resource request or limit for a pod is the sum of its containers.

To understand the difference between a limit range and a resource quota, consider that a limit range defines valid ranges and default values for a single pod, and a resource quota defines only top values for the sum of all pods in a project. A cluster administrator concerned about resource usage in an OpenShift cluster usually defines both limits and quotas for a project.

A limit range resource can also define default, minimum, and maximum values for the storage capacity requested by an image, image stream, or persistent volume claim. If a resource that is added to a project does not provide a compute resource request, then it takes the default value provided by the limit ranges for the project. If a new resource provides compute resource requests or limits that are smaller than the minimum specified by the project limit ranges, then the resource is not created. Similarly, if a new resource provides compute resource requests or limits that are higher than the maximum specified by the project limit ranges, then the resource is not created.

The following listing shows a limit range defined using YAML syntax:

```
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "dev-limits"
spec:
  limits:
    - type: "Pod"
      max: (1)
        cpu: "500m"
        memory: "750Mi"
      min: (2)
        cpu: "10m"
        memory: "5Mi"
    - type: "Container"
      max: (3)
        cpu: "500m"
        memory: "750Mi"
      min: (4)
        cpu: "10m"
        memory: "5Mi"
      default: (5)
        cpu: "100m"
        memory: "100Mi"
      defaultRequest: (6)
        cpu: "20m"
        memory: "20Mi"
    - type: openshift.io/Image (7)
      max:
        storage: 1Gi
    - type: openshift.io/ImageStream (8)
      max:
        openshift.io/image-tags: 10
        openshift.io/images: 20
    - type: "PersistentVolumeClaim" (9)
      min:
        storage: "1Gi"
      max:
        storage: "50Gi"
```

1. The maximum amount of CPU and memory that all containers within a pod can consume. A new pod that exceeds the maximum limits is not created. An existing pod that exceeds the maximum limits is restarted.

2. The minimum amount of CPU and memory consumed across all containers within a pod. A pod that does not satisfy the minimum requirements is not created. Because many pods only have one container, you might set the minimum pod values to the same values as the minimum container values.

3. The maximum amount of CPU and memory that an individual container within a pod can consume. A new container that exceeds the maximum limits does not create the associated pod. An existing container that exceeds the maximum limits restarts the entire pod.

4. The minimum amount of CPU and memory that an individual container within a pod can consume. A container that does not satisfy the minimum requirements prevents the associated pod from being created.

5. The default maximum amount of CPU and memory that an individual container can consume. This is used when a CPU resource limit or a memory limit is not defined for the container.

6. The default CPU and memory an individual container requests. This default is used when a CPU resource request or a memory request is not defined for the container. If CPU and memory quotas are enabled for a namespace, then configuring the defaultRequest section allows pods to start, even if the containers do not specify resource requests.

7. The maximum image size that can be pushed to the internal registry.

8. The maximum number of image tags and versions that an image stream resource can reference.

9. The minimum and maximum sizes allowed for a persistent volume claim.

Users can create a limit range resource in the same way as any other OpenShift resource; that is, by passing a YAML or JSON resource definition file to the oc create command:

```
[user@host ~]$ oc create --save-config -f dev-limits.yml
```

Red Hat OpenShift Container Platform does not provide an oc create command specifically for limit ranges like it does for resource quotas. The only alternative is to use YAML or JSON files.

Use the oc describe limitrange command to view the limit constraints enforced in a project:

```
[user@host ~]$ oc describe limitrange dev-limits
Name:       dev-limits
Namespace:  schedule-demo
Type                      Resource                 Min  Max    Default Request ...
----                      --------                 ---  ---    --------------- ...
Pod                       cpu                      10m  500m   -               ...
Pod                       memory                   5Mi  750Mi  -               ...
Container                 memory                   5Mi  750Mi  20Mi            ...
Container                 cpu                      10m  500m   20m             ...
openshift.io/Image        storage                  -    1Gi    -               ...
openshift.io/ImageStream  openshift.io/image-tags  -    10     -               ...
openshift.io/ImageStream  openshift.io/images      -    20     -               ...
PersistentVolumeClaim     storage                  1Gi  50Gi   -               ...
```

An active limit range can be deleted by name with the oc delete command:

```
[user@host ~]$ oc delete limitrange dev-limits
```
After a limit range is created in a project, all requests to create new resources are evaluated against each limit range resource in the project. If the new resource violates the minimum or maximum constraint enumerated by any limit range, then the resource is rejected. If the new resource does not set an explicit value, and the constraint supports a default value, then the default value is applied to the new resource as its usage value.

All resource update requests are also evaluated against each limit range resource in the project. If the updated resource violates any constraint, the update is rejected.

Important:
Avoid setting LimitRange constraints that are too high, or ResourceQuota constraints that are too low. A violation of LimitRange constraints prevents pod creation, resulting in error messages. A violation of ResourceQuota constraints prevents a pod from being scheduled to any node. The pod might be created but remain in the pending state.

## Futher Reading

   * https://sysdig.com/blog/kubernetes-pod-evicted/
   * https://sysdig.com/blog/troubleshoot-kubernetes-oom/
   * https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/
   * https://docs.openshift.com/container-platform/4.10/nodes/clusters/nodes-cluster-resource-configure.html