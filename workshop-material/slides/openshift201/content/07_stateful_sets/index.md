---
# Stateful Sets
For when you can't dump all your state

Note:
Note Placeholder


---
#### What are they good for?
Stateful sets are the answer for applications that require sticky identities (pets) for their scaling pods.

- Known/predictable pod names (app-[0..n-1])
- Unique PVC for each pod (either pre-created, or dynamically provisioned)
- Predictable startup and shutdown order (more control when re-deploying or scaling)

Note:
Note Placeholder


---
#### Pod Scaling and Updates
When a stateful set is being deployed, the pods will always have a stable hostname based on it's sequence.  

- **OrderedReady** pod management (default): 
  - Created sequentially in order from {0..N-1}.
  - Deleted sequentially in reverse order from {N-1..0}
  - Before a scaling operation is applied (either create or terminate), all of it's predecessors must be Running and Ready.

- **Parallel** pod management:
  - will launch or terminate all pods in parallel without the above restrictions.

Note:
Note Placeholder


---
##### Update strategies
Updates include changes to containers, labels, resource request/limits, and annotations for the pods.

- **RollingUpdate** *(default)*: Triggered deployment that deletes and re-creates each pod in the same order as pod termination.
- **OnDelete** : Requires manually deleting a pod before it will be updated.

Note:
Note Placeholder


---
#### PVC Storage
Each pod in a stateful set has a unique PVC.

- Must either be pre-created, or leverage a StorageClass that has auto-provisioning
- This PVC will **NOT** be deleted when scaling down or otherwise removing pods.

Note:
Note Placeholder


---
#### Key Drawbacks

- No auto-scaling
- Unique storage per pod (replication/synchronization of data is the responsibility of the application)
- Storage must be provisioned at or before creation time, and will not be removed when you delete the stateful set.

Note:
Note Placeholder


---
#### Use Case: HA Database!

- Databases provide high availability through service load balancing (clustering) and data replication (synchronizing).
- DB clustering needs to know who the cluster partners are
- Does not do well with short-lived hostnames or shared storage

Patroni is **NOT** a postgres cluster, but rather a template for you to create your own customized, high-availability solution and a toolkit to help:
- manage the postgres cluster configuration
- manage the openshift service mappings to match the postgres cluster state

Note:
- Patroni also provides an API for additional visibility and orchestration


---
#### Patroni Architecture
![Patroni Architecture](content/07_stateful_sets/01_patroni_arch_sm.jpeg)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


---
#### Lab: Create Patroni Postgres cluster

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
- Create a 3-node Postgres cluster using the patroni template


---
#### Lab: DB configuration changes
Break for Lab

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
- 15 m
- Examine different locations for configuration
- Increase max number of connections
- Change # of worker processes


---
#### Who needs DBAs?
We do!  DBA functions are still a thing.

![](content/07_stateful_sets/wait-what.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

What role has taken on the DBA functions?

Note:
Note Placeholder


---
#### Architect your DB service
- Synchronous or asynchronous updates between cluster members?
- How many replicas do you need?
- Load-balancing reads across slaves?
- Supported tools?

Note:
Note Placeholder


---
#### Operating your DB service
- Backups and restores
- Tweaking your DB settings (Dynamic, Local, Environment)
- Growing storage
- Troubleshooting when things go wrong

Note:
Note Placeholder

