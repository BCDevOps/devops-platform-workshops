# Network Security Policy
By default, the new OpenShift namespace has been configured with zero network access. 

## Testing Network Security Policy
- Attempt a simple build in the tools project

```
oc -n [-tools] new-build https://github.com/ArctiqTeam/random-beer-giphy
```

- Notice that the build will fail

## Create Basic (ZoneB) Network Security Policy
  - Process and apply provided template

```
oc -n [-tools] process -p NAMESPACE=[-tools] -f https://raw.githubusercontent.com/BCDevOps/platform-services/00091a2ea5e442260cd46b13dac1f6c7727b25e5/security/aporeto/docs/sample/quickstart-nsp.yaml
```

  - Check the status of the networksecuritypolicy objects
    
```
oc -n [-tools] describe networksecuritypolicy
```

## Testing Network Security Policy (Cont.)

- Attempt the build again

```
oc -n [-tools] start-build random-beer-giphy
```
-  Apply the same Network Security Policy to the [-dev] project 

## Cleanup Test
- Remove the previous test build

```
oc -n [-tools] delete buildconfig random-beer-giphy
```