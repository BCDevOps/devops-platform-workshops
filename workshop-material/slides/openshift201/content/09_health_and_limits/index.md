---
# Pod Health, Requests, Limits and Quotas

Note:
Note Placeholder


---
#### Health Checks

- **readinessProbe** checks whether a pod is ready/able to service requests
  - Action: add/remove the pod from the endpoint controller (service)

- **livenessProbe** checks whether the container is running.
  - Action: kill the pod and restart

- **initialDelaySeconds**: starts from container start
- **timeoutSeconds**: only applicable to external checks

Note:
- latest behavior testing seems to show that a readiness check continues to check the pod, but will kill/restart pod if it changes state from "ready" back to "not ready", and not just remove it from the endpoint controller


---
#### HTTP and TCP Socket Checks

HTTP check is successful when response is between 200 and 399

``` yaml
readinessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 15
  timeoutSeconds: 1
```

TCP Socket check is successful when a connection is successful
``` yaml
livenessProbe:
  tcpSocket:
    port: 8080
  initialDelaySeconds: 15
  timeoutSeconds: 1
```

Note:
Note Placeholder


---
#### Exec Checks

- Executes a command inside the container
  - Simple exec checks can be defined in the Probe definition
  - Complex scripts can be included in the build or mounted and executed as long as they return 0 for ok, and 1 for not ok.
  - Exec probes cannot define the timeoutSeconds, instead any timeouts would need to be added to the custom command/exec.

``` yaml
livenessProbe:
  exec:
    command:
    - cat
    - /tmp/health
  initialDelaySeconds: 15
```

``` yaml
livenessProbe:
  exec:
    command:
    - timeout 10 /app/mycustom_probe.sh
  initialDelaySeconds: 15
```
Note:
Note Placeholder


---
#### Advanced Health Check

Example: Machine learning jobs heating up the GPU after a while, causing slower computation. Moving the job to a different node can remedy this.

- Add a probe CLI tool (or a sidecar server) that queries the hardware status (GPU Temp), fail when a threshold is passed.  The new Pod will be rescheduled (to another physical node).

![Lab Time](content/09_health_and_limits/hardware-probe.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


---
#### Lab: Create a custom health check

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
- Create custom Liveness check based off of existence of a temp file.
- Change to Readiness check for available disk space in PVC to be > 10% free?
- other ideas?


---
#### Quotas

- Applied by cluster administrators to constrain the number of objects or amount of resources used in a namespace.
- **ResourceQuota** applies limits to resource consumption and/or number of objects per project
- **LimitRange** applies compute resource limits and/or defaults for individual objects per project

``` bash
oc get quota
oc describe quota {name}

oc get limitrange
oc describe limitrange {name}
```

Note:
Note Placeholder


---
#### Over Consumption

Within a shared environment, hoarding is harmful to the whole.  The closer actual consumption is to requested resources,
the better the platform can:

- schedule workload
- anticipate growth patterns for expansion
- reduce overall cost/waste

Note:
Note Placeholder


---
#### Requests and Limits

Vertical scaling with Requests and Limits

Ensure that the following snip is included in every container object definition:

``` yaml
spec:
  containers:
    image:
    ...
    resources:
      requests:
        cpu: 100m
        memory: 512Mi
      limits:
        cpu: 250m
        memory: 1Gi
```

Note:
Note Placeholder


---
#### Quality of Service Tiers

Based on the request and limit values specified for each resource:
- **BestEffort** when request and limit are not specified
  - can consume as much of the resource as available on the node, but runs at the lowest priority
- **Burstable** when request is lower than limit
  - guaranteed the requested amount, shares the rest of the node's resources equally when bursting up to the *limit* amount
- **Guaranteed** when request and limit are the same
  - guaranteed the amount of resources requested, no access to additional resources on a node

Note:
Note Placeholder

