# Docker Build Strategy Basics
In this lab, create a new application and explore the artifacts that have 
been created. 

From `bastion-01` create a new project and application; 

```
oc new-project random-beer-selector
oc new-app https://github.com/arctiqtim/random-beer-selector
```


Explore the objects created by the `new-app` command; 

```
watch oc get all
```

From the Web UI, navigate to the `random-ber-selector` project and explore; 
- Builds -> Builds
- Applications -> Deployments
- Applications -> Pods
- Applications -> Services
- Applications -> Routes

From `Overview` page, expand the random beer selector app; 
- Click `Create Route`
- Accept the defauls
- Navigate to the newly created route