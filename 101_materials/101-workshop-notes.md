# OpenShift 101 Notes

These notes are a work in progress. They are designed to support facilitators and students with the workshop content found on the [OpenShift 101 mural board](https://app.mural.co/t/platformservices5977/m/platformservices5977/1646945371597/a8a55e85f341c492d8ef9c656f2381115d6b5c65?sender=uf0df5317d8dbea9ee48c7230). These notes include material covered verbally when these slides are presented. 

## Welcome and Introduction 

### Who is here and why?
### Mural Tips
### Questions, Comments
### Learning Objectives For Today
### Agenda Part 1 
### Setting Up For Success
### What do you know about OpenShift?
### What is OpenShift?
### OpenShift is a:  Hybrid Cloud Enterprise Kubernetes Platform
### BC Dev Exchange DevOps Values
### Guidelines
### Guidelines: Architecture, Technology, Security
### Guidelines and Practices: Community
### Something went wrong! I need help!!

## OpenShift Architecture Overview

### OpenShift at a Glance
### Running Containers
### You Don't Run a Container, You Run a Pod 
### How do I scale? 
### What About My data? 
### What About Accessing Components from Outside the Platform?
### Can you securely store and manage my docker images?
### So you are telling me...
### All this Magic is orchestrated by the Master Nodes
### What about Problems? What about Autoscaling?
### Accessing OpenShift
### Service Discovery
### What is a namespace/project?
### OpenShift Objects
### Recap: what have we covered so far?

## BC Gov Specific Patterns 
### Provisioning
### Where to Start?
### Alignment
### Requests OpenShift Projects
- Namespaces are functionally separate, and the only thing they have in common is their license plate/name. You must use network policies if you need namespaces to connect to each other. 

### Request OpenShift Projects
### Project Sets cont. 
### Project Sets Example
### Resource and quota 
- Resources can be tuned more efficiently over time, as a better picture of your application's resources needs is developed. 

### Requesting New Users to Github,Rocket.Chat etc 
### Access Control in OpenShift
- For the more critical namespaces (like PROD), a limited number of people should have access. Much of the interaction with the namespace should be automated and run through a service account. 

### Tools Project
- Has it's own dedicated quota to run tools to support your application. 

### Team Roles/Functions
### Designing For High Availability
- Backup Container - can manage backing up and restoring mongodb, postgres and mysql databases. 

### Recap: what have we covered so far?

## OpenShift Basic Tasks 
### Deployments and Strategies for Deploying
### Rolling Deployments
### Recreate Deployments
### Deployments in Detail
### Deployment Triggers
### Advanced Deployments 
### Building Images
### S2I: It's as easy as pointing the BuildConfig to your Repository
### Docker Strategy 
### About the 'latest' image tag
### Be VERY careful if using :latest
### StatefulSets
### App Availability
### Recap: what have we covered so far?

## Configuring Builds and Deploys 
### Configuring Builds and Deploys 
### Designing Apps for Configuration
### What's wrong with this app?
### ConfigMaps
### Secrets
### Environment Variables
### Adding Storage
### Persistent Volume Claims Spec
### PVC Access Mode Use Cases 
### Persistent Volume Claim (PVC) Spec 
### Storage Services
### Database Utilities 
### Recap: what have we covered so far?

## ARCHITECTING A WILDFIRE API

### What is security and why should you care?
### Platform Security Tools
### Development Security Tools
### Where To Get Help
### Recap: what have we covered so far?

## Application Day 2 Operations 
### Event Streams
### Debugging Pods
### Logging and Visualizations
### Recap: what have we covered so far?

## Next Steps 
### Where to Further Your Learning
