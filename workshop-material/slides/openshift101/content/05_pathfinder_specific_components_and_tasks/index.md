---
# Pathfinder Specific Components / Tasks

Note:
Note Placeholder


---
#### Discussion and Labs (30 Minutes)
- Storage
  - RWO vs. RWX
  - Retain vs. Delete
- Databases
  - StorageClass Decisions
  - Database Utilities
- Pipelines
  - BuildConfig / OpenShift Integration
  - Persistent vs. Ephemeral Instances
  - Extending Jenkins with Plugins
  - Promotion across environments

Note:
Note Placeholder


---
#### Storage
- PVC and PV
  - Persistent Volume Claim (PVC) is a request for storage (developers create this)
  - Persistent Volume is the actual storage volume (automatically created or created by ops teams)
      - Dynamic storage provisioning is the automatic creation of a PV when a PVC is created

Note:
Note Placeholder


---
#### PVC Specs
- RWO vs. RWX
  - RWO (ReadWriteOnce) is the equivalent of having a dedicated disk attached to your app
    - Cannot be shared with other pods
    - In the infrastructure world is considered 'block' storage
  - RWX (ReadWriteMany) is the equivalend of a shared filesystems (ie. NFS) available on the network
    - Can be shared with other pods/systems
- Retain vs. Delete
  - Each Persistent Volume, by default, is created with a retention configuration of 'delete'
  - If a user deletes the Persistent Volume Claim, the Persistent Volume is deleted as well
  - An Ops team member can (upon request) reconfigure a Persistent Volume to 'retain' it's data even if the PVC is deleted 

Note:
Note Placeholder


---
#### Databases
- StorageClass Decisions for Database Storage
  - `netapp-file-standard` is currently the recommended storage class for most persistant storage solutions
  - Some databases prefer block storage for performance, in which case a case can be made to provision __Netapp Block__ storage
    - Guidance, through Rocket.Chat and Devhub, will be provided when new storage classes are released
    - These storage classes are designed to be supported by Red Hat
  - Teams are asked to utilize `netapp-file-standard` whenever possible and use `block` type storage when performance is needed in production environment.
- Database Utilities
  - Operator framework (coming, not yet released!)
  - For now: 
    - Native utilities within the container can be used for backup operations
    - Attach secondary PVC's as backup targets, or use `oc rsync` top manually copy backups to a local machine

Note:
Note Placeholder


---
#### Jenkins Pipelines - BuildConfig / OpenShift Integration
- Each application team will create their own Jenkins instance in the `tools` project
- This instance can be customized by the application team and has no dependency on other components
- [Shared Jenkins libraries](https://pathfinder-faq-ocio-pathfinder-prod.pathfinder.gov.bc.ca/Jenkins/UsingTheSharedLib.html) and documented examples exist to speed up Jenkins configuartion adoption
- Jenkins instances are automatically integrated with OpenShift for: 
  - OAuth configuration (ie. OpenShift login)
  - Pipeine build status synchronization
    - First class support for pipelines as code
  - Kubernetes/OpenShift build slave pods
  - Service account integration in the existing namespace, permitting builds, deployments, object creation/deletion, etc. 

Note:
Note Placeholder


---
#### Jenkins Pipelines - Persistent vs. Ephemeral Instances
- Persistent Jenkins masters are the most common deployment
- Often slower than ephemeral instances, however: 
  - Custom configuration is maintained across pod restarts
  - Build history is maintained
- Ephemeral instances lose all configuration  / history upon restart of a pod

Note:
Note Placeholder


---
#### Jenkins Pipelines - Extending Jenkins with Plugins
- Add additional plugins that may not be included in the base image
- Avoid manual installation by setting the INSTALL_PLUGINS environment variable
- Manual install / configuration requires persistent storage

Note:
Note Placeholder


---
#### Jenkins Pipelines - Promotion across environments
![](content/05_pathfinder_specific_components_and_tasks/cicd.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


---
#### Jenkins Pipelines - Promotion across environments
- Jenkins should only run in the `tools` project
  - Service accounts are provided access to `dev`, `test`, and `prod` projects
  - Each project service accounts group is provided `system:image-puller` role with permission to pull from the tools project
  - Image tagging should be used diligently to ensure the right images are depoyed to the appropriate namespaces

Note:
Note Placeholder


---
#### Lab Time

Lab 6 - Persistent Storage

Lab 7 - Persistent Configuration
