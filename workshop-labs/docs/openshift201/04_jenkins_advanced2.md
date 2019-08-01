## SonarQube 
In this section, deploy SonarQube into the Tools namespace and integrate it with the Blackbox build pipeline

- Deploy SonarQube into the `tools` namespace
```
oc new-app -f https://raw.githubusercontent.com/BCDevOps/sonarqube/master/sonarqube-postgresql-template.yaml --param=SONARQUBE_VERSION=6.7.5oc expose service sonarqube
```

- Log in with the default admin/admin password (and reset if you wish)
- Generage a token in the wizard for your app
![](../assets/openshift201/04_jenkins_sonary_01_.png)

## Custom Pod Template