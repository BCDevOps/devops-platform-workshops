# Persistent Storage
Up to this point you have leveraged a single mongodb pod with ephemeral storage. In order to maintain the 
appliation data, persistent storage is required.  

- Let's first take a look at our application prior to this lab
![](../assets/06_persistent_storage_01.png)

### Deleting Pods with Ephemeral Storage
To understand what will happen when a pod with ehemeral storage is removed, 
- Scale down both the rocketchat and mongo applications to 0 pods
- Scale back up each application pod to 1 replica

![](../assets/06_persistent_storage_02.png)

### Adding Storage to Existing Deployment Configurations
Now that we notice all messages and configuaration is gone, let's add persistent storage to the mongodb pod. 
- Scale down both the rocketchat and mongo applications to 0 pods
- Edit the `mongodb-[username]` configuration 
    - Remove the `emptyDir` volume
    - Add a new volume by selecting `Add Storage`

![](../assets/06_persistent_storage_03.png)

![](../assets/06_persistent_storage_04.png)

> you will notice that there options to select `gluster-file/gluster-file-db`. Provisioning for __gluster__ type storage has been disabled in favor of our new storage solution __netapp__
- Select the `net-app-block-standard` storage class, set the type to RWO (which is block storage), and the size to 1GB, with a name of `mongodb-[username]`
**note** Each application will have a preferred storage type. This is NOT the recommended storageclass for 
mongo, but is useful in an upcoming lab. 

> PLEASE NOTE: 
![](../assets/06_persistent_storage_05.png)
![](../assets/06_persistent_storage_06.png)

- Scale up `mongodb-[username]` instance to 1 pod
- When mongo is running, scale `rocketchat-[username]` to 1 pod
- Configure RocketChat again
- Scale down and scale back up both the database and the rocketchat app
- Verify that data was persisted

#### RWO Storage
RWO storage (which was selected above) can only be attached to a single pod at a time, which causes issues in certain deployment stategies. 

- Ensure your `mongodb-[username]` deployment is set to rolling

![](../assets/06_persistent_storage_07.png)

- Redeploy with Rolling Deployment

- Notice and investigate the issue

![](../assets/06_persistent_storage_08.png)

- Switch to recreate

### RWX Storage
RWX storage allows muliple pods to access the same PV at the same time. 

- Scale down `mongodb-[username]` to 0 pods

![](../assets/06_persistent_storage_09.png)

- Remove the previous storage volume and recreate as `netapp-file-standard` with type RWX

![](../assets/06_persistent_storage_10.png)

- Scale down `mongodb-[username]` to 1 pods

- Redeploy with Rolling deployment


