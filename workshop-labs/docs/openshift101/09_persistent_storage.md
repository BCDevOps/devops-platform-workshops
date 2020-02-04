# Persistent Storage
Up to this point you have leveraged a single mongodb pod with ephemeral storage. In order to maintain the 
appliation data, persistent storage is required.  

- Let's first take a look at our application prior to this lab
![](../assets/06_persistent_storage_01.png)

### Deleting Pods with Ephemeral Storage
__Objective__: Observe that by using ephemeral storage causes RocketChat to lose any previous data or configuration after a redeployment.

To understand what will happen when a pod with ehemeral storage is removed, 
- Scale down both the rocketchat and mongo applications to 0 pods
- Scale back up each application pod to 1 replica

![](../assets/06_persistent_storage_02.png)

### Adding Storage to Existing Deployment Configurations
__Objective__: Add persistent storage to MongoDB so that it won't lose data created by RocketChat.

Now that we notice all messages and configuaration is gone, let's add persistent storage to the mongodb pod. 
- Scale down both the rocketchat and mongo applications to 0 pods
- Edit the `mongodb-[username]` configuration 
    - Remove the `emptyDir` volume
    - Add a new volume by selecting `Add Storage` and name it `mongodb-[username]-block`

![](../assets/06_persistent_storage_03.png)

![](../assets/06_persistent_storage_04.png)

- Select the `net-app-block-standard` storage class, set the type to RWO (which is block storage), and the size to 1GB, with a name of `mongodb-[username]`

> PLEASE NOTE: Do NOT select any `gluster` storage class. Provisioning for __gluster__ type storage has been disabled in favor of our new storage solution called __netapp__

![](../assets/06_persistent_storage_05.png)
- The mount path is `/var/lib/mongodb/data`
- The volume name can be anything. You can use `data` for brevity.
![](../assets/06_persistent_storage_06.png)

- Scale up `mongodb-[username]` instance to 1 pod
- When mongo is running, scale `rocketchat-[username]` to 1 pod
- Access the RocketChat URL and complete the Setup Wizard again
- Scale down and scale back up both the database and the rocketchat app
- Verify that data was persisted by accessing RocketCHat URL and observing that it doesn't show the Setup Wizard.

#### RWO Storage
__Objective__: Cause deployment error by using the wrong deployment strategy for the storage class.

RWO storage (which was selected above) can only be attached to a single pod at a time, which causes issues in certain deployment stategies. 

- Ensure your `mongodb-[username]` deployment strategy is set to rolling.

![](../assets/06_persistent_storage_07.png)

- Redeploy with Rolling Deployment

- Notice and investigate the issue
> rolling deployments will start up a new version of your application pod before killing the previous one. There is a brief moment where two pods for the mongo application exist at the same time. Because the storage type is __RWO__ it is unable to mount to two pods at the same time. This will cause the rolling deployment to hang and eventually time out. 
![](../assets/06_persistent_storage_08.png)

- Switch to recreate

### RWX Storage
__Objective__: Cause MongoDB to corrupt its data file by using the wrong storage class for MongoDB.

RWX storage allows muliple pods to access the same PV at the same time. 

- Scale down `mongodb-[username]` to 0 pods

![](../assets/06_persistent_storage_09.png)

- Remove the previous storage volume and recreate as `netapp-file-standard` (mounting at `/var/lib/mongodb/data`) with type RWX, and naming it `mongodb-[username]-file`

![](../assets/06_persistent_storage_10.png)

- Scale up `mongodb-[username]` to 1 pods

- Redeploy with Rolling deployment

### Fixing it
__Objective__: Fix corrupted MongoDB storage by using the correct storage class for MongoDB.

After using the `netapp-file-standard` storage class with rolling deployment, you got to a point where your mongodb is now corrupted. That happens because MongoDB does NOT support multiple processes/pods reading/writing to the same location/mount (`/var/lib/mongodb/data`) of single/shared pvc.

To fix that we will need to replace `netapp-file-standard` with `netapp-block-standard` and change the deployment strategy from `Rolling` to `Recreate` as follow:
  - Create a new PVC using block storage with RWO
  - Scale down `rocketchat-[username]` to 0 pods
  - Scale down `mongodb-[username]` to 0 pods
  - Go to the `mongodb-[username]` DeploymentConfig and `Pause Rollouts` (under `Actions` menu on the top right side)
  - Change the deployment strategy to use `Recreate` deployment strategy
  - Remove the mount to the file storage class
  - Add a new storage (named `mongodb-[username]-block2`) and mount it at the same path (`/var/lib/mongodb/data`)
  - Go to the `mongodb-[username]` DeploymentConfig and `Resume Rollouts` (under `Actions` menu on the top right side)
  - Check a new deployment is being rollout. If not, please do a manual deployment by clicking on `Deploy`
  - Scale up `mongodb-[username]` to 1 pod, and wait for the pod to become ready
  - Scale up `rocketchat-[username]` to 1 pod, and wait for the pod to become ready
  - Access RocketChat URL and go over the Setup Wizard again
  - Check deployment and make sure `mongodb-[username]-block` and `mongodb-[username]-file` PVCs are not beings, and delete those PVCs.
