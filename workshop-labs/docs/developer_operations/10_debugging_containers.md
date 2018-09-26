# Debugging Containers

### Using a Debug Container
In this lab, edit the `mongodb-[username]` deployment config. 
- Under `spec` and `containers`, locate the line:  
    ```
              name: mongodb
    ```
- Insert the following line at the same indent level:
    ```
              command: ["touch test"]
    ```
- Once the deployment change takes effect, notice the CrashLoopBackoff

![](../assets/10_debugging_01.png)

- Click on `Debug container`
- Explore your capabilities within this container


### RSH and RSYNC
- RSH into container to test things (like curl, etc)


### Telepresence (Demonstration)
- Run test against cluster
- Demonstrate pod running in OpenShift
- Links / Use Cases
- Cleanup


### Port Forwarding
