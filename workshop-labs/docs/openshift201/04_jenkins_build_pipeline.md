# Jenkins Build Pipeline
These labs continue from the previous set, building on the previous effort & learnings. The previous lab focused on deploying items across projects, while this phase focuses on building and image and promoting that image across projects. 

## Create a New Pipeline for BlackBox Exporter Build
In this lab, create a simple pipeline that will build the blackblox exporter app within the tools namespace, and then deploy it in dev, and then in production. 

- Create the new pipeline under `blackbox_exporter/.pipeline/Jenkinsfile`

```
#!/usr/bin/env groovy

//ENV Vars
def TOOLS_NAMESPACE = "[project]-tools"
def DEV_NAMESPACE = "[project]-dev"
def PROD_NAMESPACE = "[project]-prod"


//Pipeline
node {
            stage ('Buld in Tools Namespace'){
                dir ('simple_pipeline') {
                    checkout scm
                    timeout (time: 600, unit: 'SECONDS'){
                        openshift.withCluster() {
                        openshift.withProject("${TOOLS_NAMESPACE}") {
                                def blackboxSelector = openshift.selector("bc", "blackboxexporter")
                                try {
                                    blackboxSelector.object()
                                    builds = blackboxSelector.related( "builds" )
                                } catch (Throwable t) {
                                    nb = openshift.newBuild( "https://github.com/[username]/devops-platform-workshops-labs.git#[username]-201", "--context-dir=blackbox_exporter", "--name=blackboxexporter" )
                
                                    // Print out information about the objects created by newBuild
                                    echo "newBuild created: ${nb.count()} objects : ${nb.names()}"
                
                                    // Filter non-BuildConfig objects and create selector which will find builds related to the BuildConfig
                                    builds = nb.narrow("bc").related( "builds" )
                                }
                                    openshift.selector("bc", "blackboxexporter").startBuild("--wait")
                                    builds.watch {
                                    // 'it' is bound to the builds selector.
                                    // Continue to watch until at least one build is detected
                                    if ( it.count() == 0 ) {
                                        return false
                                    }
                                    // Print out the build's name and terminate the watch
                                    echo "Detected new builds created by buildconfig: ${it.names()}"
                                    return true
                                    }

                                    echo "Waiting for builds to complete..."
                
                                    // Like a watch, but only terminate when at least one selected object meets condition
                                    builds.untilEach {
                                        return it.object().status.phase == "Complete"
                                    }
                        }
                        }
                    }

             }
        }
    }
```

- Create the buildConfig inside of the `tools` namespace

```
oc new-build https://github.com/[username]/devops-platform-workshops-labs.git#[username]-201 --context-dir=blackbox_exporter/.pipeline --name blackbox
```

- Either link up the the webhook to this build config as well, or manuall start the pipeline as required

- Add additional stage to create the app in the `dev` namespace

```
#!/usr/bin/env groovy

//ENV Vars
def TOOLS_NAMESPACE = "[project_name]-tools"
def DEV_NAMESPACE = "[project_name]-dev"
def PROD_NAMESPACE = "[project_name]-prod"


//Pipeline
node {
            stage ('Buld in Tools Namespace'){
                dir ('simple_pipeline') {
                    checkout scm
                    timeout (time: 600, unit: 'SECONDS'){
                        openshift.withCluster() {
                        openshift.withProject("${TOOLS_NAMESPACE}") {
                                def blackboxSelector = openshift.selector("bc", "blackboxexporter")
                                try {
                                    blackboxSelector.object()
                                    builds = blackboxSelector.related( "builds" )
                                } catch (Throwable t) {
                                    nb = openshift.newBuild( "https://github.com/[username]/devops-platform-workshops-labs.git#[username]-201", "--context-dir=blackbox_exporter", "--name=blackboxexporter" )
                
                                    // Print out information about the objects created by newBuild
                                    echo "newBuild created: ${nb.count()} objects : ${nb.names()}"
                
                                    // Filter non-BuildConfig objects and create selector which will find builds related to the BuildConfig
                                    builds = nb.narrow("bc").related( "builds" )
                                }
                                    openshift.selector("bc", "blackboxexporter").startBuild("--wait")
                                    builds.watch {
                                    // 'it' is bound to the builds selector.
                                    // Continue to watch until at least one build is detected
                                    if ( it.count() == 0 ) {
                                        return false
                                    }
                                    // Print out the build's name and terminate the watch
                                    echo "Detected new builds created by buildconfig: ${it.names()}"
                                    return true
                                    }

                                    echo "Waiting for builds to complete..."
                
                                    // Like a watch, but only terminate when at least one selected object meets condition
                                    builds.untilEach {
                                        return it.object().status.phase == "Complete"
                                    }
                        }
                        }
                    }

             }
        }
        stage('Promote to DEV') {
                openshift.withCluster() {
                    openshift.tag("blackboxexporter:latest", "blackboxexporter:dev")
                }
            }
        stage('Create DEV') {
            openshift.withCluster() {
                openshift.withProject("${DEV_NAMESPACE}") {
                                def blackboxdcSelector = openshift.selector("dc", "blackboxexporter")
                                try {
                                    blackboxdcSelector.object()
                                    deploymentconfig = blackboxdcSelector.related( "deploymentconfig" )
                                } catch (Throwable t) {
                                    na = openshift.newApp("${TOOLS_NAMESPACE}/blackboxexporter:dev", "--name=blackboxexporter").narrow('svc').expose()
                
                                    // Print out information about the objects created by newBuild
                                    // echo "newApp created: ${na.count()} objects : ${na.names()}"
                
                                }
                }
            }
            }
```
 
 - Extend the pipeline to deploy to the `prod` namespace as well


