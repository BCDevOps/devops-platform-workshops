# Resource Requests and Limits
Tuning the resources assigned to a pod will have a direct effect on the performance of the application. 
Many templates include reasonable CPU and Memory resource configurations, however, new apps simply are deployed with the platform default. 

## Explore Default Resource Configurations
Since the Rocket Chat application was built from scratch and not deployed from a template, explore the current resources allocated to the pods: 

- Navigate to your rocketchat deployment and select `Actions -> Edit Resource Limits`

![](../assets/11_resources_01.png)

- Notice the defaults that are applied (in a light grey to indicate they are automatically set)

![](../assets/11_resources_02.png)

- Review the current metrics of your `rocketchat-[username]` pod

![](../assets/11_resources_03.png)

- Reduce the CPU (request and limit) to `50 millicores` and Memory (request and limits) to `100 Megabytes` and monitor the startup time of the pod
  ```oc:cli
  oc -n [-dev] set resources dc/rocketchat-[username] --requests=cpu=50m,memory=100Mi --limits=cpu=50m,memory=100Mi
  ```
- Monitor the startup events of your pod and measure the time it takes to start
  ```oc:cli
  # Start new deployment; and
  oc -n [-dev] rollout latest dc/rocketchat-[username]

  # Wait for deployment to finish
  time oc -n [-dev] rollout latest dc/rocketchat-[username]
  ```
- Remove the limits previously imposed, and set your pod to `1 core` (or `1000 millicores`) for the request and limit
  ```oc:cli
  oc -n [-dev] set resources dc/rocketchat-[username] --requests=cpu=1000m,memory=512Mi --limits=cpu=1000m,memory=1024Mi
  ```
![](../assets/11_resources_04.png)

- Monitor the status and speed of the new deployment
  ```oc:cli
  # Start new deployment; and
  oc -n [-dev] rollout latest dc/rocketchat-[username]

  # Wait for deployment to finish
  time oc -n [-dev] rollout latest dc/rocketchat-[username]
  ```
- Work with the rest of the class to determine why some pods may have succeeded, and others are failing. 
