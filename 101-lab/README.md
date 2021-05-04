## 101 Lab

This directory contains all the contents and infrastrcture to run an instance of the ocp 101 lab. 


## To Run

1. Locally:
  You can build and deploy the docker image with `docker build -t 101-lab:1.0.0 .` and `docker run -p 2015:2015 101-lab:1.0.0`

2. OpenShift:
  You can deploy this to openshift by processing and applying the `app.yaml` openshift template:
  ```shell
  oc -n [-tools] process -f app.yaml -p APP=[ocp101-march] | oc -n [-tools] create -f -
  ```
