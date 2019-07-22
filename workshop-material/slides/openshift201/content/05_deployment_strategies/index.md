---
# Deployment Strategies

Note:
Note Placeholder


---
![](content/05_deployment_strategies/deployment_intro.jpg)

Note:
Note Placeholder


---
#### Deployment Styles Recap
- Standard OpenShift Deployment Styles
    - Rolling vs. Recreate
    - Rolling
        - Supports life-cycle hooks for injecting code into deployment process
        - Waits for pods to pass readiness check before scaling down old components
        - Does not allow pods that do not pass readiness check within timeout
        - Used by default if no strategy specified on deployment configuration
    - Recreate
        - Has basic rollout behavior
        - Supports life-cycle hooks for injecting code into deployment process
        - Steps in recreate strategy deployment:
        - Execute pre life-cycle hook
        - Scale down previous deployment to zero
        - Scale up new deployment
        - Execute post life-cycle hook
    - Rollbacks
    - Triggers

Note:
Note Placeholder


---
#### Canary Releases
- Canary Release
  - Simple implementation is with a Rolling deployment strategy
  - Traffic is never routed to the new version if readiness probes do not succeed
  - The more advanced the readiness indicator, the better the outocomes
  - Other interpretations and implementations of this could be: 
    - slowly releasing a new version of the application gradually to the same set of users and monitoring errors
    - deploying to a subset of users with separate environments

Note:
Note Placeholder


---
#### Blue - Green 
- Technique for releasing application in predictable manner
    - Goal: Reducing downtime associated with release
- Quick way to both:
    - Prime application before releasing
    - Quickly roll application back if you find issues
- Two identical environments (infrastructure): "blue" and "green"
- 'Green' environment hosts current production applications
- Run two different versions of application side by side
- After validating new software version, can switch all traffic to new version
- Lets you update and roll back code and databases in one step

Note:
Note Placeholder


---
#### Blue/Green deployment
- Completely re-route traffic to new version of the application
- Easily roll back to existing *running* version if errors arise
- Otherwise, remove old version of application when ready

![](content/05_deployment_strategies/deployment_blue-green.png)<!-- .element style="border: 0; background: None; box-shadow: None; height: 80%; width: 80%;" -->

Note:
Note Placeholder


---
#### A/B Testing
- Method of testing application features
    - Test for usability, popularity, noticeability, etc.
    - Also how these factors influence bottom line
- Usually associated with application UI
- Back-end services need to be available to implement
- Can implement with either application-level or static switches

Note:
Note Placeholder


---
#### A/B via Percentage or Separate Route
- Gradually direct *some* users to the new version
- Monitor feature performance
- Remove new feature and roll changes into main build

![](content/05_deployment_strategies/deployment_a_b.png)<!-- .element style="border: 0; background: None; box-shadow: None; height: 40%; width: 40%;" -->

Note:
Note Placeholder


---
#### Blue/Green vs A/B Testing
- A/B testing measures application functionality
- Blue-green deployment releases software safely and lets you roll back predictably
- Can combine the two:
    - Use blue-green deployments to deploy new features
    - Use A/B testing to test those features

Note:
Note Placeholder


---
#### Canary via Percentage
- Gradually direct *some* users to the new version
- Monitor application health (logs, apm, etc)
- Increase percentage of users directed to the new version until 100%

![](content/05_deployment_strategies/deployment_canary.png)<!-- .element style="border: 0; background: None; box-shadow: None; height: 40%; width: 40%;" -->

Note:
Note Placeholder


---
#### Lab:

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder