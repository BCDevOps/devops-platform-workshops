# Creating a custom health check

In this lab we will create a custom health check and insert it into our patroni containers.

## Create a custom script

In order to execute a custom check script, it will need to be accessible from within the containers.  We will mount a configMap that contains a custom script that we can execute in parallel with our other health checks.

- create a custom health check script

``` bash
cat << EOT > lab-check.sh
# test to see if /tmp/badfile does not exist
test ! -e /tmp/badfile
EOT
```

- create the temporary configmap

``` bash
oc create configmap checks --from-file lab-check.sh
```

Add the following to the appropriate locations in the deployment.yaml to mount the configmap in the /opt directory.

*Add with GUI and can export the template*

- update the configuration of the stateful set

- once the pods have re-deployed, you can rsh to a pod and run the script to see it work.  Simply touch a file called `/tmp/badfile` to force a check failure.

## Add the liveness test
Add the following section right after the readinessProbe:

``` yaml
          livenessProbe:
            initialDelaySeconds: 5
            failureThreshold: 4
            exec:
              command:
                - . /opt/lab-check.sh
```
