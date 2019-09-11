---
# Pathfinder Specific Patterns

Note:
Note Placeholder


---
#### Provisioning Workflows
- Team Provisioning
- Project / Namespace Provisioning
- Access Control Between Projects / Namespaces
- Tooling Project Components

Note:
Note Placeholder


---
#### Team Provisioning
- Rocket.Chat #devops-requests channel is used to add members to GitHub/Rocket.Chat/OpenShift
- Groups/GitHub Teams are NOT widely used today
    - Individual usernames are used for collaborating on projects
- Team 'admins' are delegated access control for their teams

Note:
Note Placeholder


---
#### Project / Namespaces Provisioning
- Platform Services team provisions projects/namespaces
- In OpenShift, project and namespace are the same thing
- 4 projects are created per team/application
    - [project-name]-tools
        - All the devopsy goodness (Jenkins, sonarqube)
    - [project-name]-dev
        - General development workspace
    - [project-name]-test
        - Pre-prod testing happens here
    - [project-name]-prod
        - The place where your production app lives
- All projects live in the same production OpenShift cluster

Note:
Note Placeholder


---
#### Project / Namespaces Provisioning
![](content/03_pathfinder_specific_patterns/projects.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


---
#### Access Control Between Projects
- Each project has it's own:
    - Network isolation
    - User access control policy
- Team 'admins' can determine who should have access to each project
- Separate rights can be applied in each project/namespace
- The 'tools' project will have service accounts that need access to all other projects for as a function of CI & CD processes

Note:
Note Placeholder


---
#### Tooling Project Components
- CI & CD related tooling
- Jenkins instance dedicated to a given team
- Sonarqube for code coverage
- Teams can bring any additional tools into this project space as needed

Note:
Note Placeholder


---
#### Team Roles / Accountability
- Developer Functions
- DevOps Functions
- Platform Ops Functions

Note:
Note Placeholder


---
#### Developer Functions
- Creating awesome code and apps, duh!
- Providing in-depth knowledge and support of the applications in production
- Developing to support a 'cloud-native' framework such that platform operations do not disrupt application availability

Note:
Note Placeholder


---
#### 'DevOps' Functions
![](content/03_pathfinder_specific_patterns/devops.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


---
#### 'DevOps' Functions
- Access permissions
    - Adding / removing team members for collaboration
    - Creating service accounts across namespaces
- Tagging procedures
    - Ensuring a consistent codified tagging structure to support new deployments
- Pipeline setup between environments
    - Configuring the codified CI & CD pipelines (ie. Jenkinsfiles) between projects
- Build orchestration / support
    - Supporting developers with specific build needs such as s2i modifications, secret management, etc.
    - Determining how best to share resources across projects
- Application operations
    - Updating / roll-back of releases
    - Backup/restore of persistent data

Note:
Note Placeholder


---
#### Platform Ops Functions
- Maintain availability of the core OpenShift platform
    - Console/API
    - Routers
    - Logging / Metrics
    - Storage
- Monitor and add capacity as required
- Investigate and resolve systemic issues that occur across projects

Note:
Note Placeholder

