## Namespace Created!
@{{name}}, your namespace/project set has been created. 

{{#each namespaces}}
  -{{this}}
{{/each}}

You should be able to view them at https://console.pathfinder.gov.bc:8443

You can also confirm that you have the namespaces by logging onto the `oc cli` and running the command
`oc get project` to verify the above namespaces exist. 


## Important Notes

- these namespaces have a restricted quota
- these namespaces will be automatically deleted on {{endDate}}
