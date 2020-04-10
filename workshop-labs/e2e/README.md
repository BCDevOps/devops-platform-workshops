## Openshift 201 End to End Testing

This directory contains a suite of shell scripts that test the lab content. The style of testing is
more 'functional' it attempts to mimick what students are directed to do as best as possible. The goal
for this e2e test is to be run prior to every ocp201 course so that the facilitator can verify the course
is working, versions are correct etc. 

## Authoring E2E Tests

Here's suggestions for authoring E2E tests. 

### Naming Convention

- filenames: the file names should mimick the lab content it is supposed to test. Please also prefix this
name with a number so that the tests can be run serially. 

eg: the lab `02-advanced-oc-practice.md` would have the e2e test `04-02-advanced-oc-practice.sh`.

> the '02' refers to the gitbook chapter this document is destined for. We do not want to run tests
based on chapters. Some tests are dependant on each other and need to be garaunteed to run in order.

### Variable Naming

Long running variables in your scripts should be named in __SCREAMING_SNAKE_CASE__

### Prompts

- Prompts should be written in __present continous__ tense. 
eg: 'Applying latest oc changes' __NOT__ 'Apply latest changes'

- Prompts that confirm an action has completed should be written in __past tense__
eg: 'Latest changes applied succesfully' __NOT__ 'Latest changes were applied'

### Testing Conventions
- All tests should validate whether the machine has all dependancies and tools such as jq, sponge etc
- All tests should verify if dev, test, and prod (if needed) exist
- All tests should cleanup any transient files that are created
- All tests should NOT cleanup openshift artifacts.
- Tests are split up into __describe__ blocks
  - describe blocks are a __function__ that preformats a message
  - describe blocks are 1-1 with lab content main headers. Such as [## Deploy Grafana Using OpenShift Tools](../docs/openshift201/02_building_openshift_templates.md#Deploy-Grafana-Using-Openshift-Tools)
  - describe blocks are numbered
  eg. The first header is run with `describe 1 "msg"` and the second header is run with `describe 2 "msg2"`

- Within __describe__ blocks any smaller steps are prompted with a __character__ starting with lowercase
__'a'__.

- Assertions should be made with the __assert__ function and should exit with process 1 if the assertion fails.

