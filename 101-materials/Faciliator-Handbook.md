
## How to use

TO DO

# Day 1

## Common Questions

- How long are the namespaces available for?

  I tell the class that the namespace will be available for up to a week. This is manually deleted so it is a bit inconsistent!

- How much does it cost to join the platform?

  From the application teams perspective, there is zero cost to run in Openshift, Openshift is capital expenditure for the OCIO. No cost is relayed to other Ministries.
 

## Some Considerations
You will be working with a mixed bag of individuals with a wide array of skill sets. Some may not be
technically trained and may have never interacted with a command line tool!

People will be running the workshop on a variety of operating systems. Most of our lab examples assume you are using a unix based terminal, for windows users this is not helpful when they are told to run commands like `grep`!

## Format
Days are from 9AM to 4PM. 

### Day 1
- lecture heavy for the morning
- 1hr lunch break
- labs in the afternoon

### Day 2
- less lectures, then labs at your own pace
- 1hr lunch break

## 8:30 AM - 8:50AM Setup
- Turn on AC to cool down room if its stuffy,
- ensure there are enough extension cords and power bars for everyone
- clean up anything thats not tidy
- Test your laptop connects to the tv correctly 
- Clean up the whiteboard

## 9:00 AM - 9:15 AM Introduction
> Lead Facilitator
- Ensure AC is off
###  Opening Remarks (things to include): 
- Standard introduction (Traditional Territory Acknowledgement) 
- Washroom locations (2nd and 3rd floor of Exchange Lab), 2nd floor has a pw! _54321_                                        
- In case of fire, muster point across Broughton, it is in-between the church and the Broughton street parkade
- Lunch is for 1 hour, I like to give the class the choice on when they want to take it but usually it should be between 11:30 and 12:15
- Introduce the facilitators and get a round table intro from attendees (this also helps to identify the technical skills  spectrum)                                                     
- Ask the class if they have specific learning goals and write them on the board, if they are within scope and you have time try and include them into the workshop:)
- Talk about what they can expect to learn out of the course, this is essentially verbatim from the eventbrite description
- Talk about the workshop structure, lectures in the morning and labs in the afternoon (day 2 is mostly labs)
- Talk about Openshift 201, this is a pre req for that course and that we are rolling our more courses for it. 

## 9:15AM to [however long this takes] Tools setup
>You will need to ensure all attendees are set up for success. They require:
> - access to Rocketchat and join the OCP 101 channel for your course. 
> - a Github Account with 2FA enabled, if anyone doesn't have 2FA, demonstrate how to enable it. 
> - They should be a member of BCDevOps Github Organization
> - They should have `oc cli` at the correct version (right now that is 3.11). Demonstrate how to check version with `oc version`

> Lead Facilitator
- Demonstrate how to access rocketchat at https://chat.pathfinder.gov.bc.ca. Explain how this is one of our
sources for community and information. It's thriving and the members list is increasing daily :) ! 
- Demonstrate how to find the OCP 101 channel they will be working from. If you haven't already, post all the helpful links
that are noted in the [101-Prereqs document](../101-Prerequisites.md), including links to your instance of the slides and labs
- Ask all attendees to post their Github ID into the rocket chat channel. This will allow your co facilitator to check their github ids against the BCDevOps Org and add them to it if needed. 
- Demonstrate opening up the command terminal for people who are unfamiliar with cli's and how to check your oc version (for Windows users they may be using Command prompt, powershell, gitbash, or other tools)
> Co Facilitator
- once students list their github ids in rocketchat, verify their ids are in the github BCDevOps org and add them if not. Let the class know to check the email they registered their github account with for an email if they were invited. 
  It is helpful to add a reaction checkmark icon beside their github id message in rocketchat when completed

> From here on pacing the slides will be variable based on you, and how many questions you are asked. Try to hit these deadlines for a nice flow :)

# Lectures
The lecture section is based on the devops platform workshop slides. I've noted some key points to get across during the slides and a rough guideline for times. Timing I feel will be variable based on class size, number of questions, and your tempo. 

## 9:30AM Who, What, Where
Things to talk about:
[ to do]

## 9:45AM Openshift Architecture
Things to talk about:

### Very high level overview
  - Ask if people know what an image/container is. If they do not know or are unsure, give them a brief high-level
  explanation of what they are
  - Ask if people know what kubernetes is (give a brief explanation of how it orchestrates running containers, explain that Openshift is built on top of kubernetes and provides a ton of features
  - Openshift can run anywhere RHEL can run
  - Openshift provides services that are needed to run a enterprise level containerized platform
    - role based access control
    - self service tools/catalog
    - image building
    - application lifecycle automation (this may not be a real thing since we don't really use the built in jenkins)
  - As development teams typically the green portion of the overview image is what you will deal with
  - Final Point: At the end of the day Openshift run's containers. Full stop.

### Run My Container
  This slide needs some love but in the meantime, talk about how running a container in Openshift is not as straightforward as just pressing a magic button. There is a lot more too it (and for good reason!)

  > for docker users, explain that its not as simple as using `docker run ...`

### Runs on your choice of infrastructure
  - from the platform operations perspective you first need to have Openshift installed somewhere
  - this is not a development team task but it is important to know that your apps will be running inside of Kamloops data center on physical machines!

### One or more docker containers run as a unit: a pod

  - the smallest deployable unit in Openshift/Kubernetes is a pod. 

  - a pod can be comprised of 1 to n containers. In our platform it is generally a 1 to 1 ratio between pods and the containers inside of them.

  - all containers within a pod share the same assigned ip.

  - pods are assigned a new ip every time they are created

### Where do pods run?

  - just like in traditional infra, a host is needed to the run the process
  - in Openshift, a node is where pods are run
  - we currently have 20 + (we are procuring more application nodes as we speak) nodes for running pods
  - all application based nodes are run on physical hardware in the data center

### I want to scale
- to scale your application, you scale pods

At this point I like to point out with a 1 node cluster there are some issues. I ask the class what is wrong with a 1 node cluster? 

_You can scale up pods but if the node goes down so does your application_

>  this is a good time to explain the key differences between containerized platforms and traditional infrastructure. Containers come and go, you depend on the lightweightedness and portability of an image to reliably spawn instances of an image (a container) quickly and across a variety of platforms. Whenever a node goes down for maintenance all the pods that were running go down with it. In summary, we don't care to keep pods running for as long as possible. Up time is not a consideration. We care that we can bring up a new pod to replace dead ones quickly and reliably. In traditional infrastructure, you depend on up time, if things go wrong it can be a tenuous process to bring your app up back to life. 


### Additional Nodes Provide Capacity

- we scale by adding nodes as capacity is needed. Right now there are 20 + application nodes
> ask the class how many instances of an application (how many pods) should be running at a minimum to be considered highly available?
The answer is generally 3. This allows for one pod to be lost due to node evacuation, and another pod to be lost due to an unexpected failure. 

- multiple instances of your application can, and most likely will exist in different nodes, how do they communicate with each other, how is data shared?

### What about my data

- users claim for storage (PVC), they ask for the amount of storage and where to attach it to a pod 
- storage exists in nodes that are outside of the application nodes. Depending on configuration many pods could be attached to the same storage volume

### I have components that need to communicate internally
- A node is a shared environment where pods for different applications are running. Some are related to your product. Some not. How do pods communicate with each other?
- The service layer acts like a liason for pod to pod communication.
- Pods cannot communicate with pods from other projects/namespaces through the service layer
- Because pods are assigned a different api they are created it is practically impossible to have a stable direct connection
- With the service layer, you typically communicate via the internal DNS (ie the Service name) for a given set of like pods. 
- It is important to lose the notion that you want to speak from 'Pod A to Pod B'. Rather what you care about is speaking from 'Pod A to Pod B's Service'. The service will correctly route and load balance traffic. 

### What about access from the outside?

- external clients communicate with pods via the routing layer.
- the user creates a route which provides access over the web using http/https/ws ports 80, 443 __ONLY__
> this is a security consideration, non web ports/protocols are not accessible from outside the cluster

### Can you securely store my docker images
- whenever images are created in openshift they are stored securely in the internal docker registry.
- you can only pull images that you are authorized to pull
> ie you cannot pull a images from 'Namespace A' to use in 'Namespace B' without `image-pull` access

### This sounds like magic
- recap everything: services, routing, storage, docker registry
- explain that behind the scenes there are master nodes that control all of this in the background

### Thou shalt AuthN/AuthZ 
- AuthN stands for who are you?
- AuthZ stands for what are you allowed to do?
- Authentication is controlled by the master nodes

### What goes where?
- A scheduler also exists on the masters and that tells where to run pods on what nodes

### What about problems? Auto scaling?
- the platform can provide auto scaling capabilities based on CPU utilization thresholds

### Access via WEB, CLI, IDE, API

- users do not interact with nodes directly, they instead work with a variety of tools to interact with OCP
- The Web Console and CLI ultimately leverage the same API to interact with Openshift

### Single Site HA Deployment
- This is an example of a single site cluster deployment
- multiple masters for redundancy,
- infrastructure nodes are separate from app nodes and masters
- application nodes can be scaled to provide additional capacity

### External Data Flow
- just go over this schematic, its fairly straight forward

### Network Segregation and Service Discovery
- double up on that pods do not communicate to pods directly. YOu leverage the service DNS record inside your application to communicate instead. 
> I like to demonstrate the difference between a traditional mongo connection string with an ip, and one that uses a service name as the 'host'


> When it gets to around 10:30, 10:45ish check in with the class, if they are glazing over suggest going for a quick 10 minute break to stretch their legs!
## Pathfinder Specific Patterns

### Project Name Space Provisioning
> explain that we use the term project and 'namespace' interchangeably. Kubernetes calls them namespaces, openshift calls them projects but they are the same thing.

- provisioning is done through rocket chat and has a few pre requisites
- the application must have a product team
- the product team must have a product owner that has had an alignment meeting with Todd Wilson
- When your project/namespace is provisioned you will get 4 projects in what we call a __'Project Set'__
- Explain the differences between these 4 projects and their uses. 
> teams can bring additional tooling they find helpful to their namespaces with the notion it is up to them to support and maintain it.

### Access Control Between Projects
> I find it is easiest to illustrate what namespaces are
- draw out two rectangles on the white board approx 12"x12" side by side. (these are your application nodes)
- inside the two rectangles draw a few different 'pods'. These pods should fit inside the nodes. 
- identify name spaces by a dotted line and expplain that pods from different namespaces can exist in different nodes
- the name space is like a bubble wrap that seperated pods from different namespaces. They cannot communicate to each other within the service layer
![img1](./IMG_0405.png)
![img1](./IMG_0406.png)


### Remaining slides are pretty explanatory 


## 11:00AM General Openshift Tasks 
> at this point it is up to you how you want to divy up slides and lab work. I like to do the deployment/build labs together and so I only go over those slides initially. This gives time to answer and questions and fill any gaps between those labs and persistant storage.

> Ask the class if they can name any of the Openshift Objects that we have already pointed out and write them on the board
> Pods, Nodes, Namespaces, Services, Routes, Storage (PVC)

- although the slides dives right into deployments, we have found it helpful to talk about how images are built in openshift
  - images are built using 'BuildConfig' Objects
  - BuildConfigs take source code and typically a base image or a docker file to create another image
  - Common build strategies are S2I and Docker strategy (go into those if they are interested)
> add BuildConfig and ImageStreams/ImagestreamTags to the object list (you may have to answer questions about what an image stream is, this is easier done after discussing deployment triggers)

## Project Access Control
- all namespaces must have atleast one admin, it is up to the admins to delegate access control and be aware of what that means

> Let the class know that they will need one person to serve as the 'Dev Ops Specialist' in the labs, this is so that they can be granted admin priviledges and add other members to the namespaces. Ask for a volunteer and assign one if no one volunteers. As a tip, the devops specialist can delegate other users to add team members by giving them admin privildges to speed up this process. 

- demonstrate how to access the cluster at https://console.pathfinder.gov.bc.ca:8443
> only users that belong to BCDevOps org can see the cluster

- demo the two namespaces and show how to add your volunteer as a member with admin privileges in the gui
- demo how to add a user via the command line using `oc policy`
> this may require you to show them the login command. Explain that the login command is long lives (it cycles every 12 hours) and should not be shared or distributed. If someone gets that token they can impersonate you!
> it is helpful to show that all `oc` commands have the `-h` helper flag which is REALLY useful!

### 11:20AM to 12:00PM Deployment Styles, and remaining slides before deployment labs
> let the class know they will be getting to the labs fairly soon and will be spending the rest of the day on them (unless they are quick!)
> they have already done the first lab exercise by working with project access control together and can ignore the first lab exercise in the lab website
- in addition let them know there are some examples that will only work if you have admin priviledges. Demonstrate those examples for the class so no one is left out
> if you are running late or getting close to lunch time just take a break and get back to this after lunch!

- explain that deploymentconfigs tell openshift how to run pods. If the class is into it, show them the `spec.containers` and `spec.replicas` inside of a deployment config yaml file
- add deployment config to your openshift objects list
- explain that deployment configs create `ReplicationControllers` which ultimately is responsible for deploying your pods. 
> RC's are snapshots of your DC during a deployment or rollback, this way RC's maintain the state of how your pods were configured, what images they used and can be rolled back too :)
- add ReplicationController to the object list

> Sometimes it is helpful to draw a mind map of how all objects, BC to Pod are connected

## Lunch Time (1 hr)
- turn ac on if the room is stuffy and turn it off back as people are coming back

## Labs (Builds and Deployments)
This is a good time to say that the labs are designed to fail at certain points. We encourage the students to read
further ahead and troubleshoot. If they are having issues though we are happy to help!

- the builds can take some time, it is not unusual for them to take up to 18minutes!
- monitor where builds and deploys are happening, builds should be in tools, deploys in dev
- when someone gets the image pull back off issue take a moment to explain what is going on. 

### Registry Console
the registry console is iffy, some students have not been able to access it :( . I explain that it is a way to 
visualize and track changes in your image history. The same information is presented in your images in the Openshift GUI however

### Autoscaling

There has been confusion of pod scaling when autoscalling is turned off. __If your pods have been scaled up by__ the autoscaler and then you remove it. It will _NOT_ automatically scale down. You will have to manually do this. 

Similarily if you manually scale a deployment, it will not rescale between deployments. (if it was scaled to zero, it will stay at zero!)


# Day 2

TO DO

## Bonus Demonstrations

### `oc explain`
Demonstrate how amazing oc explain is to understand different object specs
`oc explain bc.spec.foo` for example

### Building and Deploying From Scratch
If the class is speedy and you have a couple of hours at the end of day two. One thing I've offered is demonstrating how to run a simple application from start to finish leveraging:
- S2I builds
- Saving configuration as code and running with `oc apply`
- Running a simple deployment (again using `--dry-run` then `oc apply`) using `oc new-app` 
> *keep in mind oc new app will create an image stream in your deploy namespace which is not needed

If there is a lot of time, I actually demonstrate how to convert Openshift objects into templates and how to leverage them with the BCDK start to finish. This includes standing up Jenkins, creating jobs, and setting up a pipeline for the app. This obviously requires familiarity with using the bcdk for such purposes.
