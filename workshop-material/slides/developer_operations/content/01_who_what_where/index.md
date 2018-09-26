---
# Who, What, Where (20  Minutes)

Note:
We will focus on the three groups that support the Pathfinder Platform


---
#### (Who) are the people?
- Ministry development teams (ie. You!) / platform users
- Platform support teams
    - DevOps Platform Services (OCIO DevOps/BCDevExchange Branch prime, Arctiq support)
        - Clecio Varjao - DevOps Specialist, Todd Wilson - Director
        - Onboarding/project provisioning
        - Assistance and education of platform users
        - Improvements in platform usability
        - Education / hands-on knowledge transfer
        - Community Leadership        
    - Technical Platform Operations (DXC/ESIT prime, Arctiq support)
        - Dan Deane - Team Lead, Steven Barre, William Hutchison - Platform Admins
        - 24x7 operational support of the platform (DXC on-call team)
        - Patching, upgrades, etc. 
        - Platform service improvement (new platform-wide features/capabilities)

Note:
Note Placeholder


---
#### Pathfinder
- Ongoing OCIO initiative
- Testbeds for government to explore the potential of emerging technology solutions, and to capture the benefits. 
- Deliver business value through a 'learn by doing' process, matching known business problems with emerging technologies.
- Releasing leading edge solutions to production.
- What is learned is shared, so other projects have a path to follow, with a focus on corporate enablement.
- To facilitate speed and innovation, Pathfinder projects are provided greater latitude when adhering to existing standards 
- The learning gathered will inform any necessary standards/revisions going forward.

Note:
Note Placeholder


---
#### BC DevExchange DevOps Values
- Speed of delivery and continuous product improvement OVER governance, standardization and legacy compatibility.
- Strong preference for Open Source development and frameworks.
- Select mainstream stacks that have upward momentum in Dev community
- Architect solutions leveraging containerization, micro services and APIs from the start.
- Data is bound to the line of business and shared through API integration.

Note:
Note Placeholder


---
#### General Guidelines
![](content/01_who_what_where/guidelines_meme.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


---
#### General Guidlines - Architecture and Technology
- Leverage platform-provided templates/components when possible
    - Already adapted for OpenShift
- Supported by RedHat (updates, patches, etc.)
- Security is to be considered at every stage of the application lifecycle
- Use 'cloud-native'/12factor architectures/principles (https://12factor.net/)
- Leverage/survey community for assistance/opinions on technology choices/approaches 
- Leverage platform’s DevOps pipeline tooling
- Assume continual evolution/improvement of applications on platform
- Recognize shared aspect of platform - some level of uniformity required
- Design applications for resiliency/high availability
- Infrastructure and tooling should sit alongside code (e.g. DeploymentConfigs, BuildConfigs, Jenkinsfiles)
- Compose applications from re-usable components and share on GitHub

Note:
Note Placeholder


---
#### General Guidelines - Community & Communication
- Product Teams should aim for self-sufficiency WRT management of pipelines, definition of OCP assets, deployments, scaling, monitoring, etc.
    - Training, tutorials, books, are available to help with the learning curve
- Community (Internet, and Gov) are the support mechanisms - not individual DevOps Team resources
- Primary communication mechanism is (currently) Slack
    - Teams should  monitor (for alerts/notifications, etc.) and participate (answer questions, share findings, etc.)
    - Follow community conventions/etiquette WRT use of specific channels, appropriate @ mentions, DMs, etc.
- Technical team members should join and participate in DevOps Commons community - meetups, etc.
- Product Owner/Managers should join Product Manager commons
- Teams should share timelines of major milestones (e.g. first release, expected increased volume) ahead of time with PM Commons and platform team

Note:
Note Placeholder


---
#### Where are the tools and additional resources?
- OpenShift
    - Production cluster in Kamloops
        - [https://console.pathfinder.gov.bc.ca:8443/console/](https://console.pathfinder.gov.bc.ca:8443/console/)
- Slack
    - Pathfiner slack [instance](https://devopspathfinder.slack.com)
        - #general - team-wide / work related announcements
        - #requests - requests for access to github, slack, and openshift
        - #alerts - platform wide alerts / announcements
        - #help-me - community sourced assistance across teams
        - #operations - watch and participate in platform operations discussions
- GitHub
    - bcgov GitHub [cheatsheet](https://github.com/bcgov/BC-Policy-Framework-For-GitHub/blob/master/BC-Gov-Org-HowTo/Cheatsheet.md)
    - BCDevOps GitHub [organization](https://github.com/orgs/BCDevOps)
    - OpenShift Wiki [gitbook](https://pathfinder-faq-ocio-pathfinder-prod.pathfinder.gov.bc.ca/) [github-source](https://github.com/BCDevOps/openshift-wiki)

Note:
Note Placeholder


---
#### Help, my production app is down?
![](content/01_who_what_where/support.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->
- Phone: 250-387-7000
- Email: 77000@gov.bc.ca

Note:
Note Placeholder


