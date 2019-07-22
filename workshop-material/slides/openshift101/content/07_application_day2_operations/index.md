---
# Application Day 2 Operations
Note:
Note Placeholder


---
#### Discussion and Labs (30 Minutes)
- Application Day 2 Ops
  - Event Streams
  - Pod / Container Debugging
  - Storage Debugging
  - Logging Visualizations

Note:
Note Placeholder


---
#### Event Streams
- Events can be viewed
    - From the CLI or Web Console
    - At the project level, or the object (ie. pod) level
    - Default is to expire after 2 hours
- Provides valuable troubleshooting detail if not related to specific container issues
    - Storage / configMap mount issues
    - Scheduling issues
    - ImagePullBackoff issues
- Specific container issues arise through CrashLoopBackoff events
    - The container itself has an issue, unrelated to the items above
    - Debug the container locally or through an OpenShift debug pod
  
Note:
Note Placeholder


---
#### Debugging Pods 
- Local container debugging
- Debug pod options
- rsh, rsync, and logs 
- [Telepresence](https://www.telepresence.io/) (for local to shared platform debugging in development)
- Port-forwarding (for app specific debugging)
  
Note:
Note Placeholder


---
#### Storage Debugging
- Common mounting issues
    - Storage is already mounted (RWO)
    - Cannot find [configmap, secret, pvc]
    - Forbidden to mount (hostpath)
- Filesystem permissions and how to debug them
    - runAsUser
    - fsgroup
- Full filesystem

Note:
Note Placeholder


---
#### Logging and Visualizations
- Kibana for accessing aggregated application logs
    - Navigating to the archive link
    - Simple queries across the namespace
    - Queries across multiple namespaces
- Simple visualizations for application logs with Kibana

Note:
Note Placeholder


---
#### Lab Time

[Lab 8 - Event Streams](http://labs-devops-platform-workshops.lab.pathfinder.gov.bc.ca/developer_operations/08_event_streams.html)

[Lab 9 - Debugging Containers](http://labs-devops-platform-workshops.lab.pathfinder.gov.bc.ca/developer_operations/09_debugging_containers.html)

[Lab 10 - Logging and Visualizations](http://labs-devops-platform-workshops.lab.pathfinder.gov.bc.ca/developer_operations/10_logging_and_visualizations.html)

[Lab 11 - Resource Requests and Limits](http://labs-devops-platform-workshops.lab.pathfinder.gov.bc.ca/developer_operations/11_resource_management.html)

[Lab 12 - Pod Lifecycle](http://labs-devops-platform-workshops.lab.pathfinder.gov.bc.ca/developer_operations/12_pod_lifecycle.html)
