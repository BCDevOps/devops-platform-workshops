---
# Github Flow

Note:
(30m)
Add/Speak to ideas about why Github Flow (and not GitFlow)


---
#### What are flows anyway?
Flows are the way we organize our collaboration.

- Sharing is hard
- Rules make it easier
- Rules are driven by the goals, contraints, and teams
- With many variables, there are many options and opinions

Note:
Note Placeholder


---
#### Pathfinder variables

- Pathfinder promotes sprint based development for smaller/faster releases to production
- Teams can have flexible memberships
- Ramp-up needs to be fast

Note:
Note Placeholder


---
#### Git Flow

![](content/01_github_flow/07_gitflow-2.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

- Allows for complex parallel feature development and structured integration into releases
- Lots of moving parts and integration points

Note:
Note Placeholder


---
#### GitHub Flow (Pathfinder recommended)

![](content/01_github_flow/07_github-flow-light.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

- Focuses on shorter feature branches and faster iteration
- Less complexity to manage
- Fast startup for new teams

Note:
Note Placeholder


---
#### Get Started with a new Branch
![](content/01_github_flow/01_githubflow-branch.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Create a branch for your feature.

- one rule: `master` branch is always deployable!

Note:
Note Placeholder


---
#### Commit Changes
![](content/01_github_flow/02_githubflow-commit.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Add commits for your feature.

- descriptive commit messages are super helpful

Note:
Note Placeholder


---
#### Pull Request
![](content/01_github_flow/03_githubflow-pr.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Open a Pull Request (PR)

- Earlier PR is better to let other people comment and contribute sooner!

Note:
Note Placeholder


---
#### Feedback
![](content/01_github_flow/04_githubflow-collab.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Get Feedback!, integrate changes, more commits!

- Github PR comments are in markdown, which allows for nicer formating and embedded images.

Note:
Note Placeholder


---
#### Deploy
![](content/01_github_flow/05_githubflow-deploy.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Deploy from your branch for validation and testing.

- Can deploy to prod from your branch to allow for easier rollback if your branch causes prod issues.

Note:
Note Placeholder


---
#### Merge
![](content/01_github_flow/06_githubflow-merge.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Merge your code to the master branch to finalize your change.

- A merged PR can automatically close any linked issue too!

Note:
Note Placeholder


---
#### Lab: Git Branch and PR
Break for Lab (15m)

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
- Each person creates a personal fork of the main lab repository
- Each person creates a branch/PR for their work

