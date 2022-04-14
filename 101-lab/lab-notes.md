# Lab Notes

This file contains some notes on what topics should be covered during each of the lab meetings, in order to ensure that things go smoothly and we don't forget stuff! This document is intended for the lab facilitators, to provide guidance on what topics to cover during each meeting.

## Prep

- create a rocketchat channel of the form `#ocp101-YYYY-MM-DD` with date being the date of the training session (the day before kickoff)
- clean up the `d8f105` namespaces (let's make a script for this?)
- post this following message in the RC channel and pin:

```
Useful links:

OCP tools namespace: https://console.apps.silver.devops.gov.bc.ca/topology/ns/d8f105-tools?view=graph
OCP dev namespace: https://console.apps.silver.devops.gov.bc.ca/topology/ns/d8f105-dev?view=graph
lab material: https://ocp101-labs-d8f105-tools.apps.silver.devops.gov.bc.ca/
lab repo if you’d like to host the material later on: https://github.com/BCDevOps/devops-platform-workshops/tree/master/101-lab
Just Ask, to request an invite to our GitHub orgs: https://just-ask-web-bdec76-prod.apps.silver.devops.gov.bc.ca/
```

## Kick-Off

The day after the training, the lab has a kick-off meeting, during which we set up all the necessary access, provide an introduction to Openshift and the lab itself, and answer questions.

- General Lab Intro Information
    - lab is self-directed over about 2 weeks
    - 3 meetings
    - if you aren't finished in the next 2 weeks, let us know and we'll do what we can to keep your access to the namespaces a little longer
    - point out and show off links to the lab content and content repo
- RocketChat and GitHub Access
    - Everyone sign into RocketChat and join the channel (show them how?)
        - Mention the "new user sign-ups disabled" message, and to ignore it and click login anyway.
    - Post your GitHub username in RocketChat
    - Is everyone a member of the BCGov orgs in GitHub? If not, use the Just Ask link.
- OpenShift Tour (while we set up everyone's RocketChat and GitHub Access)
    - Tour of the OpenShift console
    - How to download the CLI
    - How to log in to the CLI (if recording, make sure to pause on screenshare)
    - Show the lab namespaces
        - Talk about the namespace name (how the lab will sometimes use `ocp101-tools` or `[-tools]` and what to use instead)
        - Mention that the attendees don't have access yet, not to worry!
- Lab Step 1: Access Control
    - Talk about the "team" format of the lab (aka most of you are devs, but we need a few devops specialists to be your admins)
    - Get volunteer admins (at least two)
    - Walk through the process of adding people to the namespace
        - Mention the need to include `@github` and the fact that names are lowercase only
    - Get the admins to work through the rest of the list
- Tips and Tricks
    - show off `oc explain` and `-h` flag
    - mention the deployment vs deploymentconfig issue (there is a step where you're asked to issue an `oc rollout` command which won't work - you can skip this step)
- Questions?

## Mid-Lab Check-In

- Questions? 
- Talk about Infrastructure As Code
    - TODO: Maybe let's build an example set of yaml files that produces everything from the lab? Then the teams can look at this and use it as an example!
    - Why is Infrastructure as Code a good idea?
    - How are yaml manifests laid out?
    - How do I generate yaml files? How do I apply them?
    - What about templates?

## Wrap-Up

- How far did everyone get?
    - Should we leave the lab stuff up for you guys?
- Questions?
- Services and Best Practices (don't worry, there are links and notes that will be posted about this!)
    - Databases
        - Already used MongoDB - the second most popular DB on the cluster
        - Postgres is the most popular, and can be implemented in a few ways:
            - Patroni is most common; you can use our images in either `bcgov` or Artifactory!
            - EDB Operator is for teams with a license - this nets you additional enterprise-level support. Talk to Olena!
            - CrunchyDB offers both enterprise and community licenses. Still new to the cluster!
        - Our community has built an awesome backup-container, super easy DB backups! Take advantage of it!
    - Images and Artifacts
        - Artifactory:
            - an artifact repository that can be used to host/access docker images, libraries and packages, helm charts, etc. 
            - includes artifact scanning so you can make sure to use secure artifacts and images!
        - Common images: pre-built docker images we have created for teams to use!
            - Includes Postgres, MongoDB, AppAssessment
    - KeyCloak
        - an SSO (Single Sign-On) solution that lets your app use IDIR login, plus also GitHub IDs and BCeID
    - Sysdig
        - monitoring app so you can track your resource usage
        - notifies you of problems, like if your pod goes down or if your PVC is getting full
    - Vault
        - encrypted secret storage!
    - Network Policies
        - All namespaces on our cluster are deny access to all network traffic by default. You must explicitly allow your pods to talk to each other.
        - You didn't have to worry about this in the lab because we made a network policy for you, but you'll need to make one on your own.
        - Make sure you allow only the network traffic you actually need (use RC as an example?)

```
**Database Stuff**
- Patroni - HA Postgres 
   - templates and docs: <https://github.com/bcgov/patroni-postgres-container>
   - rocketchat channel: #patroni 
- EDB - HA Postgres with enterprise support
   - note that you will need a license BEFORE you can start any work with this solution (talk to olena about costs)
   - templates and docs: <https://github.com/bcgov/platform-services-edb-template>
   - rocketchat channel: #edb
- CrunchyDB - HA Postgres that we're still testing on the cluster
   - DM me or shelly if you want in on the PoC work!
- Backup Container - easy-to-deploy backup solution for Postgres/Mongo/MariaDB 
   - templates and docs: <https://github.com/BCDevOps/backup-container>
**Images/Artifacts**
- Artifactory - artifact repository which caches public repositories and provides private repositories for teams. Includes security scanning.
   - docs: <https://github.com/BCDevOps/developer-experience/blob/master/apps/artifactory/DEVHUB-README.md>
   - UI: https://artifacts.developer.gov.bc.ca
   - rocketchat channel: #devops-artifactory 
- Common Images - the Platform Team creates certain images for teams to use, including one for Mongo and one for Patroni
   - pull images from artifacts.developer.gov.bc.ca/bcgov-docker-local
   - docs: <https://github.com/BCDevOps/openshift-wiki/blob/master/docs/Artifactory/common_images.md>
- Xray Scanning - artifact scanning solution build into Artifactory
   - you gain access to this automatically for any image you put into a private repo on Artifactory!
**Monitoring**
- Sysdig - monitoring solution to provide notifications about the status of your app,
   - documentation: <https://github.com/BCDevOps/platform-services/tree/master/monitoring/sysdig
- Platform Status page to let you know if any platform services are experiencing an outage: <https://status.developer.gov.bc.ca/>
**SSO**
- Keycloak - primary SSO provider on the platform
   - documentation: <https://github.com/bcgov/sso-keycloak/wiki/>
**Secrets**
- Vault - a secret storage solution that encrypts your private information like passwords
   - UI: <https://vault.developer.gov.bc.ca/ui>
   - docs and templates: <https://github.com/BCDevOps/openshift-wiki/tree/master/docs/Vault>
**Network Policies**
    - docs: https://github.com/bcgov/how-to-workshops/tree/master/labs/netpol-quickstart
```