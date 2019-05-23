# Openshift 101 Lab Healthcheck/Troubleshooting guide

## Who is this for?

This document is geared towards Openshift 101 workshop facilitators/trainers

## What does this guide do?

Over several sessions we have found some common issues that arise during the lab excercises.

As facilitators it is helpful to know where members of the training course are in their workshop and also
identify if there are any workshop level issues due to things beyond your control such as faulty nodes, cluster maintainence. 

@cvarjao has created a set of tests that provide information on:

- what stage the class is at during the lab
- are lab excercises operational? (can you create build configs)
- get insight on member specific troubleshooting


## How To Use

> Requires Node JS 10 or higher
> Requires oc cli 3.11

Ensure you are in the `support` directory.

Ensure you are logged into the oc client. In your command terminal run `oc whoami` this should return your github id. If it does not you are not logged in!

Create a file called `properties.local.json`. From the support directory `cp test/properties.local.example.json test/properties.local.json` (this is how you troubleshoot a specific members lab)

### Testing If Lab Functions are operational at time of the lab

Run `npm test`.

You should see the following tests __PASS__ 
- Can I create RoleBinding
- Can I create BuildConfig

The other tests __WILL NOT PASS__ at this stage. This is because the remaining tests have dependancies on images be created for rocketchat/mongo etc. 

### Health Check of the class during the lab

You may run `npm test` from time to time. You should see more tests pass as the labs continue.


## Troubleshooting a specific Lab

Update the `properties.local.json` with the person's github id. 

```json
{
  "username": "foo"
}
```

And then run `npm test`