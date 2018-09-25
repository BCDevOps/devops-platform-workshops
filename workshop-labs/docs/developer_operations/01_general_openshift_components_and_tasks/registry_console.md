# Interacting with the Registry Console

## Accessing the Registry Console
The registry pods all reside within the `default` project. The `docker-registry` and `registry-console`
are separate pods that help provide access to the internal registry. 

Find the registry console URL (or obtain this from your instructor); 
- With a user with `cluster-admin` rights; 

```
oc get route -n default
```

- OR navigate to the `default` project in the UI and select `Applications -> Routes`
![](../assets/registry_console.png)

Navigate to the url:
- https://registry-console-default.apps.cloud.lab

Explore the main dashboard and attempt to push/pull docker images with the instructions provided (in the dashboard).
Attempt to do this from `bastion-01`. You will likely need to add the registry address as an `--insecure-registry` registry
to your docker configuration, and may in fact need to install docker. This may be different based on your chosen version 
of docker. In the lab this can be added in `/etc/sysconfig/docker` or `/etc/docker/daemon.json`

An example docker configuration file for `bastion-01` is as follows: 

```
# /etc/sysconfig/docker

# Modify these options if you want to change the way the docker daemon runs
OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false --insecure-registry docker-registry-default.apps.cloud.lab'
if [ -z "${DOCKER_CERT_PATH}" ]; then
    DOCKER_CERT_PATH=/etc/docker
fi

# Do not add registries in this file anymore. Use /etc/containers/registries.conf
# from the atomic-registries package.
#

# On an SELinux system, if you remove the --selinux-enabled option, you
# also need to turn on the docker_transition_unconfined boolean.
# setsebool -P docker_transition_unconfined 1

# Location used for temporary files, such as those created by
# docker load and build operations. Default is /var/lib/docker/tmp
# Can be overriden by setting the following environment variable.
# DOCKER_TMPDIR=/var/tmp

# Controls the /etc/cron.daily/docker-logrotate cron job status.
# To disable, uncomment the line below.
# LOGROTATE=false

# docker-latest daemon can be used by starting the docker-latest unitfile.
# To use docker-latest client, uncomment below lines
#DOCKERBINARY=/usr/bin/docker-latest
#DOCKERDBINARY=/usr/bin/dockerd-latest
#DOCKER_CONTAINERD_BINARY=/usr/bin/docker-containerd-latest
#DOCKER_CONTAINERD_SHIM_BINARY=/usr/bin/docker-containerd-shim-latest
```


