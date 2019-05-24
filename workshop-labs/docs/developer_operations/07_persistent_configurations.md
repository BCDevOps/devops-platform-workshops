# Persistent Configurations
In cases where configurations need to change frequently or common configurations should be shared across deployments or pods, it is not ideal to build said configurations into the container image or maintain multiple copies of the configuration. OpenShift supports `configMaps` which can be a standalone object that is easily mounted into pods. In cases where the configuration file or data is sensitive in nature, OpenShift supports `secrets` to handle this sensitive data. 

### ConfigMaps

#### Creating a Config Map and Adding it to a Deployment
Create a configMap with arbitrary data and mount it inside of your `rocketchat-[username]` pod: 

- In the Web Console, create a `configMap` by navigating to `Resources -> Config Maps`
*Note* this can be performed directly from the deployment, or independently as these steps illustrate

![](../assets/07_persistent_config_01.png)

- Name your configmap `rocketchat-[username]-configmap`, add an arbitrary key (ie. file name) and content; add as many files as you like

![](../assets/07_persistent_config_02.png)

- Attach the `configMap` to your `rocketchat-[username]` deployment by nativating to the `Configuration` tab and selecting `Add Configuration Files`

![](../assets/07_persistent_config_03.png)
![](../assets/07_persistent_config_04.png)

- This change will trigger a new deployment of your `rocketchat-[username]` pod
- Using the pod terminal in the Web Console or `oc rsh`, explore the path of the mounted configMap

![](../assets/07_persistent_config_05.png)

#### Changing Config Map Content
The content in your `configMap` can be changed and is dynamically updated in the pod. With that said, if the application does not support live reload of its configuration, a new deployment will be required for the changes to be picked up. 

- Edit your `configMap` to change the content of the file or add a new file

![](../assets/07_persistent_config_06.png)

- Using the pod terminal in the Web Console or `oc rsh`, explore the path of the mounted configMap

![](../assets/07_persistent_config_07.png)



### Secrets
Secrets can be added in a similar way as config maps but are geared towards the management of sensitive information. In OpenShift, these are base64 encoded, and encrypted on disk when stored in the cluster. In Pods, they never live on disk (unlike configmaps) and are only in memory.
Secrets, from the Web Console, are focused on supporting: 
- Username/Passwords
- SSH Keys
- SSL Certificates
- Git config files

"Opaque" secrets are supported and can contain any type of data, however, these must be configured on the commandline with the `oc` cli. 

- In the Web Console, create a `secret` by navigating to `Resources -> Secrets -> Create Secret`
*Note* this can be performed directly from the deployment, or independently as these steps illustrate

![](../assets/07_persistent_config_08.png)


- Name your secret `rocketchat-[username]-secret`, add an arbitrary username/data or SSH key

![](../assets/07_persistent_config_09.png)

- Explore the other mongo secrets to see different variaions of secret data

![](../assets/07_persistent_config_10.png)

- Attach the `secret` to your `rocketchat-[username]` deployment by nativating to the `Configuration` tab and selecting `Add Configuration Files`

- Select the `secret` and set the mount directory; split up the keys into separate files if you like

![](../assets/07_persistent_config_11.png)

- This change will trigger a new deployment of your `rocketchat-[username]` pod
- Using the pod terminal in the Web Console or `oc rsh`, explore the path of the mounted `secret`

![](../assets/07_persistent_config_12.png)

- From the cli, review the secret with `oc describe secret rocketchat-[username]-secret`

```
oc describe secret rocketchat-sheastewart-secret
Name:         rocketchat-sheastewart-secret
Namespace:    devops-training-rc-dev
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/basic-auth

Data
====
password:  11 bytes
username:  11 bytes
```

- Export the secret to view the contents with `oc get --export secret rocketchat-[username]-secret -o yaml`

```
oc get --export secret rocketchat-sheastewart-secret -o yaml
apiVersion: v1
data:
  password: c2hlYXN0ZXdhcnQ=
  username: c2hlYXN0ZXdhcnQ=
kind: Secret
metadata:
  creationTimestamp: null
  name: rocketchat-sheastewart-secret
type: kubernetes.io/basic-auth
```

- In order to reveal the contents of each key, base64 decode is required
*Note* The Web Console automatically performs the base64 decode

```
echo "c2hlYXN0ZXdhcnQ=" | base64 -d
```

- To edit an existing secret, use `Edit Yaml` from the Web Console or `oc edit secret rocketchat-[username]-secret` from the cli

![](../assets/07_persistent_config_13.png)
![](../assets/07_persistent_config_14.png)


- The updated content must be base64 encoded manually if updating in-place

```
echo "randomnewguy" | base64
cmFuZG9tbmV3Z3V5Cg==
```

Or visit https://www.base64encode.org/ for encoding & decoding base64
 
- Similar to `configMaps`, the updated secret is automatically applied to the pod; no additional deployment is required

![](../assets/07_persistent_config_15.png)
