# Logging and Visualizations

### EFK for Aggregated Logs
The OpenShift platform provides an aggregated logging stack that is automatically configured to centralize and store logs from application pods. These logs are only retained for a short period of time, currently about 14 days, but can be used to help identify issues with appliation pods. 

Kibana is the primary interface for viewing and querying logs. 

#### Access the archive link from a pod
The shortcut towards accessing the Kibana is from the `Logs` tab of a running pod. 

- Select the runing `rocketchat-[username]` pod and select the Logs tab

![](../assets/12_logging_01.png.png)

- Select the view archive link to be taken to Kibana

- Review the 


#### Access the kibana interface directly 
    - Explore filters, etc. 
#### Simple queries across namespaces
#### Simple Visualizations

