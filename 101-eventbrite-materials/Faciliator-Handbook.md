
# How to use

TO DO

## Common Questions

- How long are the namespaces available for?

  I tell the class that the namespace will be available for up to a week. This is manually deleted so it is a bit inconsistent!

- How much does it cost to join the platform?

  From the application teams perspective, there is zero cost to run in Openshift, Openshift is capital expenditure for the OCIO. No cost is relayed to other Ministries.
 

## Some Considerations
You will be working with a mixed bag of individuals with a wide array of skill sets. Some may not be
technically trained and may have never interacted with a command line tool!

People will be running the workshop on a variety of operating systems. Most of our lab examples assume you are using a unix based terminal, for windows users this is not helpful when they are told to run commands like `grep`!

## 8:30 AM - 8:50AM Setup
- Turn on AC to cool down room if its stuffy,
- ensure there are enough extension cords and power bars for everyone
- clean up anything thats not tidy
- Test your laptop connects to the tv correctly 
- Clean up the whiteboard

## 9:00 AM - 9:15 AM Introduction
> Lead Facilitator
- Ensure AC is off
Opening Remarks, things to include: 
- Standard introduction (Traditional Territory Acknowledgement) 
- Washroom locations (2nd and 3rd floor of Exchange Lab), 2nd floor has a pw! 54321                                        
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
- once students list their github ids in rocketchat, verify their ids are in the github bcdevops org and add them if not. Let the class know to check the email they registered their github account with for an email if they were invited. 
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

### One or more docker contaienrs run as a unit: a pod

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

>  this is a good time to explain the key differences between containerized platforms and traditional infrastructure. Containers come and go, you depend on fairly lightweight image reliable places to spawn instances of image (a container) quickly and reliably. Whenever a node goes down for maintenance all the pods that were running go down with it. In summary, we don't care to keep pods running for as long as possible. Up time is not a consideration. We care that we can bring up a new pod to replace dead ones quickly and reliably. In traditional infrastructure, you depend on up time, if things go wrong it can be a tenuous process to bring your app up back to life. 


### Additional Nodes Provide Capacity

- we scale by adding nodes as capacity is needed. Right now there are 20 + application nodes
> ask the class how many instances of an application (how many pods) should be running at a minimum to be considered highly available?
The answer is generally 3. This allows for one pod to be lost due to node evacuation, and another pod to be lost due to an unexpected failure. 

- multiple instances of your application can, and most likely will exist in different nodes, how do they communicate with eachother, how is data shared?

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

## 10:30AM Break 15 minutes
- this is a lot of information so ask if people want to take a break
- if they do turn on the ac (if it's warm) and make sure to turn it off once the workshop resumes

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


## Bonus Demonstrations

If the class is speedy and you have a couple of hours at the end of day two. One thing I've offered is demonstrating how to run a simple application from start to finish leveraging:
- S2I builds
- Saving configuration as code and running with `oc apply`
- Running a simple deployment (again using `--dry-run` then `oc apply`) using `oc new-app` 
> *keep in mind oc new app will create an image stream in your deploy namespace which is not needed

If there is a lot of time, I actually demonstrate how to convert Openshift objects into templates and how to leverage them with the BCDK start to finish. This includes standing up Jenkins, creating jobs, and setting up a pipeline for the app. This obviously requires familiarity with using the bcdk for such purposes.
