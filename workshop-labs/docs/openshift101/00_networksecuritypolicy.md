# Network Security Policy
By default, the new OpenShift namespace has been configured with zero network access. 

- Attempt a general build

```
oc new-build https://github.com/ArctiqTeam/random-beer-giphy
```

- Notice that the build will fail

- Create the 3 basic NetworkSecurityPolicy objects
  - Obtain the sample policy
    
    ```
    wget https://raw.githubusercontent.com/BCDevOps/platform-services/master/security/aporeto/docs/sample/quickstart-nsp.yaml
    ```

  - Modify the policy with the appropriate namespace

    ```
    ---
    apiVersion: secops.pathfinder.gov.bc.ca/v1alpha1
    kind: NetworkSecurityPolicy
    metadata:
      name: egress-internet
    spec:
      description: |
        allow the [INSERT NAMESPACE HERE] namespace to talk to the internet.
      source:
        - - $namespace=[INSERT NAMESPACE HERE]
      destination:
        - - ext:network=any
    ---
    apiVersion: secops.pathfinder.gov.bc.ca/v1alpha1
    kind: NetworkSecurityPolicy
    metadata:
      name: intra-namespace-comms
    spec:
      description: |
        allow the [INSERT NAMESPACE HERE] namespace to talk to itself
      source:
        - - $namespace=[INSERT NAMESPACE HERE]
      destination:
        - - $namespace=[INSERT NAMESPACE HERE]
    ---
    apiVersion: secops.pathfinder.gov.bc.ca/v1alpha1
    kind: NetworkSecurityPolicy
    metadata:
      name: int-cluster-k8s-api-comms
    spec:
      description: |
        allow [INSERT NAMESPACE HERE] pods to talk to the k8s api
      destination:
      - - int:network=internal-cluster-api-endpoint
      source:
      - - $namespace=[INSERT NAMESPACE HERE]

    ```
  - Apply the policy again

    ```
    oc apply -f quickstart-nsp.yaml
    ```

  - Check the status of the networksecuritypolicy objects
    
    ```
    oc describe networksecuritypolicy
    ```

- Attempt the build again

```
oc start-build random-beer-giphy
```

- Remove the previous test build

```
oc delete buildconfig random-beer-giphy
```
