---
# Exploring Objects

Note:
Note Placeholder


---
#### OpenShift API objects

The best place to find documentation for your objects:

``` bash
oc api-resources

oc explain {objectType}

oc explain {objectType}.{field}
```

Note:
Note Placeholder


---
#### Interesting Objects

- **cronjobs** are k8s scheduled jobs that manage the scheduling of specific job containers
https://github.com/BCDevOps/backup-container/blob/master/openshift/templates/backup/backup-cronjob.yaml

- **routes** are the method used to expose services outside of the cluster (or namespace)
  - BlueGreen example: https://docs.openshift.com/container-platform/3.11/architecture/networking/routes.html#alternateBackends
  - Annotations for security: https://docs.openshift.com/container-platform/3.11/architecture/networking/routes.html#whitelist
- **poddisruptionbudgets** are used to define the max disruption that can be caused to a collection of pods.

Note:
Note Placeholder

<!-- 
---
#### Bonus Round: Cronjob

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Build your own cronjob using the backup deployment as a starting point. -->

