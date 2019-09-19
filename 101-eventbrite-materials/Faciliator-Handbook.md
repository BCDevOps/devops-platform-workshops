
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

People will be running the workshop on a variety of operating systems. Most of our lab examples assume you are
using a unix based terminal, for windows users this is not helpful when they are told to run commands like `grep`!

## 8:30 AM - 8:50AM Setup
- Turn on AC to cool down room if its stuffy,
- ensure there are enough extension cords and power bars for everyone
- clean up anything thats not tidy
- Test your laptop connects to the tv correctly 
- Clean up the whiteboard

## 9:00 AM - 9:15 AM Introduction
> Lead Facilitator

Opening Remarks, things to include: 
- Standard introduction (Traditional Territory Acknowledgement) 
- Washroom locations (2nd and 3rd floor of Exchange Lab), 2nd floor has a pw! 54321                                        
- In case of fire, muster point across Broughton, it is in-between the church and the Broughton street parkade
- Lunch is for 1 hour, I like to give the class the choice on when they want to take it but usually it should be between 11:30 and 12:15
- Introduce the facilitators and get a round table intro from attendees (this also helps to identify the technical skills  spectrum)                                                     
- Ask the class if they have specific learning goals and write them on the board, if they are within scope and you have time try and include them into the workshop:)
- Talk about what they can expect to learn out of the course, this is essentially verbatim from the eventbrite description
- Talk about the workshop structure, lectures in the morning and labs in the afternoon (day 2 is mostly labs)


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

## 9:30AM Who, What, Where
Things to talk about:
[ to do]

## 10:00AM Openshift Architecture
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
  - tbd





## Bonus Demonstrations

If the class is speedy and you have a couple of hours at the end of day two. One thing I've offered is demonstrating how to run a simple application from start to finish leveraging:
- S2I builds
- Saving configuration as code and running with `oc apply`
- Running a simple deployment (against using `--dry-run` then `oc apply`) using `oc new-app` *keep in mind oc new app will create an image stream in your deploy namespace which is not needed

If there is a lot of time I actually demonstrate how to convert Openshift objects into templates and how to leverage them with the BCDK start to finish. This includes standing up Jenkins, creating jobs, and setting up a pipeline for the app. This obviously requires familiarity with using the bcdk for such purposes. 
