# Network Security Policy
By default, the new OpenShift namespace has been configured with zero network access. 

## Testing Network Security Policy
- Attempt a general build

```
oc new-build https://github.com/ArctiqTeam/random-beer-giphy
```

- Notice that the build will fail

## Create Basic (ZoneB) Network Security Policy
  - Process and apply provided template

    ```
    oc -n ocp101-tools process -p NAMESPACE=ocp101-tools -f https://raw.githubusercontent.com/BCDevOps/platform-services/00091a2ea5e442260cd46b13dac1f6c7727b25e5/security/aporeto/docs/sample/quickstart-nsp.yaml
    ```

  - Check the status of the networksecuritypolicy objects
    
    ```
    oc describe networksecuritypolicy
    ```
## Testing Network Security Policy (Cont.)

- Attempt the build again

```
oc start-build random-beer-giphy
```

## Cleanup Test
- Remove the previous test build

```
oc delete buildconfig random-beer-giphy
```

## Create Basic (ZoneB) Network Security Policy