---
# OpenShift Architecture Overview

Note:
Note Placeholder


---
#### Very High-Level Overview
![](content/02_openshift_architecture_overview/overview.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
OpenShift is more than just Kubernetes. Highlight the role that k8s plays in the overall platform. 


---
#### Run My Container
![](content/02_openshift_architecture_overview/01_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
I just want to run my container somewhere. Can the platform do that?
It absolutely can. But there’s a lot more to it.


---
#### Runs on your choice of infrastructure
![](content/02_openshift_architecture_overview/02_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Ultimately your container can run anywhere RHEL is supported.
OpenShift is designed to run anywhere RHEL can run. It can be deployed to physical machines or virtual machines that live in the data center, or in private and public clouds. 
This includes running on bare metal physical servers, on your choice of virtualization platform (including RHEV/KVM, vSphere, Hyper-V), private cloud platforms like OpenStack or certified public cloud providers like Amazon, Google and more.
With Openshift, you can also take a hybrid cloud approach and deploy instances of OpenShift Enterprise to both private and public clouds.
There are a lot of things between your container and the underlying infrastructure, though.


---
#### One or more Docker containers run as a unit: A Pod
![](content/02_openshift_architecture_overview/03_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Whether your container is a self-contained application or a piece of a bigger multi-container application, the deployable “unit” is a Pod.
A Pod has a single IP address that all containers must share, and is connected to the platform’s software-defined network.
All containers in a pod will ultimately run on the same host.


---
#### A Node is the host where Pods run.
![](content/02_openshift_architecture_overview/04_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
All of the hosts where Pods run in an environment are called Nodes.
The Node is just a RHEL or Atomic instance with Docker, the platform software, and some other bells and whistles.


---
#### I want to scale!
![](content/02_openshift_architecture_overview/05_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Eventually, you may want to scale out the application or service. How does the platform handle this?


---
#### Additional nodes provide capacity
![](content/02_openshift_architecture_overview/06_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Multiple nodes provides for capacity and high availability.


---
#### What about my data? 
![](content/02_openshift_architecture_overview/07_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
The persistent storage subsystem allows an abstraction between real-world storage volumes and application instances.
Users claim storage volumes and then tell the platform where that storage should be attached inside their Pod.
The platform ensures that the storage is connected to the Pods no matter where the Pod end up in the environment.


---
#### I have components that need to communicate internally
![](content/02_openshift_architecture_overview/08_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
A busy environment has lots of different pods running, some you care about and some you don’t. The Service layer is responsible for connecting pods together, both inside and across nodes.
Rewriting your application every time the endpoints change location or change in number is not practical, so the Service layer handles the hard work for you.

Users create Services to abstract their endpoints using a simple Label/Selector model.
Applications are written to communicate with the Service, either by the Service IP or by the Service’s internal DNS name.
The platform keeps track of Service endpoints and automatically proxies and load balances connections across the endpoints.


---
#### What about access from outside the platform?
![](content/02_openshift_architecture_overview/09_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Not everything lives inside the platform, and the routing layer provides access for external resources. External clients communicate with user defined “routes”. Users create routes using a similar label/selector model. The routing layer, like the service layer, keeps track of route endpoints, and load balances and proxies those external connections to the endpoints. The routing layer is pluggable and the default implementation uses HAProxy. HAProxy runs in pods inside the platform and receives all the same platform benefits. A typical N-tier application involves several platform components:

The routing layer, for client access to the “front end” (eg: Tomcat/App)
The service layer, for the “front end” to access the data store / database (eg: MongoDB)
Persistent storage, where the application data lives (eg: NFS)


---
#### Can you securely store and manage my Docker images?
![](content/02_openshift_architecture_overview/10_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
The platform has an integrated Docker registry that runs in one or more pods (for HA) and consumes persistent storage.
The integrated registry provides many benefits, like auto-detection of image change which can trigger deployments of the new images. RBAC, etc etc.
Images can be consumed from any network-accessible V2 registry, whether or not the internal registry is used. However, some automated features are not available with external registries.


---
#### This sounds like magic.
![](content/02_openshift_architecture_overview/11_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
There is a lot of magic going on, and it is coordinated by the Master. The master is the brains of the operation and is responsible for orchestration of all activities in the cluster. The master itself can be made highly available, too.


---
#### Thou shalt AuthN/AuthZ
![](content/02_openshift_architecture_overview/12_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
The master is responsible for authentication (AuthN - who are you?) as well as authorization (AuthZ - what can you do?). All requests for the platform to do things must go through the APIs and must be properly authenticated. The APIs are protected with SSL and all client-master and master-node communications are encrypted. The platform’s authentication and authorization can be tied to external systems (LDAP, Active Directory, OAuth, external trust, and more)


---
#### What goes where?
![](content/02_openshift_architecture_overview/13_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
The Scheduler is what determines which Pod goes on what Node. 
A platform administrator examines the real-world topology (zones, racks, regions, datacenters, DMZs, and more) and configures the scheduler accordingly using a simple JSON plain-text configuration file. 
The Scheduler uses a scoring algorithm that involves filters and priorities, and many factors are taken into consideration: available and requested resources, where existing components are, and more. 
Ultimately, a particular node “wins” the workload and it is run there.


---
#### What about problems? What about autoscaling?
![](content/02_openshift_architecture_overview/14_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
The Master is responsible for managing application health and scale.
Probes can be defined to determine if applications are alive or ready and the platform will restart instances accordingly
Users can specify application scale and the platform maintains the correct number of instances at all times
The platform can additionally automatically scale pods based on target CPU utilization


---
#### Access via web, CLI, IDE, API
![](content/02_openshift_architecture_overview/15_flow.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Users need no direct access to the Nodes. They can perform all of their functions, including troubleshooting inside containers, through the existing interfaces.
CI/CD toolchains can consume and talk to the platform APIs to drive automated deployment.
Operations management can be done using typical and existing tooling. CloudForms can also be used to monitor capacity and utilization of the platform.
All of these interactions are ultimately performed through the encrypted, authenticated and authorized API.
The API is completely RESTful and every platform component is represented as a serializable data model object (eg: JSON/YAML)


---
#### Single-site HA Deployment
![](content/02_openshift_architecture_overview/single_site_ha.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


---
#### External Data Flow (routes)
![](content/02_openshift_architecture_overview/routes.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


---
#### Network Segregation and Service Dicovery
- Multitenant SDN
    - Each project is an isolated network namespace
    - Access into the namespace is granted via `routes`
    - Namespaces can be 'joined' by the ops team if required (not a common practice)
        - Joining is discouraged to promote communication through public API's
- Internal service discovery enables pods to automatically comunicate
    - Services automatically obtain a dns record 
        - `service-name.namespace.svc.cluster.local`
    - Discover can be shortened to just the service name within a project
        - ie. `curl http://service-name`
        - Simplifies configuration file management

Note:
Note Placeholder