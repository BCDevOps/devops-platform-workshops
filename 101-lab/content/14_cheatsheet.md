# Cheatsheet
This is a placeholder to work with the students and determine what they find valuable in this sheet. 

## Deleting your lab
- Don't delete your lab work yet if you're planning to complete the 'pod lifecycle' and 'templates' sections of the course! Move on to those first. 

__WARNING__: You should ALWAYS validate the output before using `oc delete`. You can do that by replacing `oc delete` with `oc get`, or if using with xargs prefix with `echo`.

__WARNING__: Always double check, and triple check before running `oc delete`!!!

__WARNING__: Be very careful when copying and pasting directly into a terminal!!!

```
# List/validate resources to be deleted by labels
oc -n [-tools] get all -l build=rocketchat-[username]

# Delete by labels
oc -n [-tools] delete all -l build=rocketchat-[username]

# List/validate resources to be deleted by get+grep+delete
oc -n [-dev] get all,pvc,secret,configmap -o name --no-headers | grep -i -F -e '-[username]'

# Delete resources by using get+grep+delete
oc -n [-dev] get all -o name --no-headers | grep -i -F -e '-[username]' | xargs -I {} oc  -n [-dev] delete '{}'

# Delete data/unrecoverable resources (not covered by 'all') by using get+grep+delete
oc -n [-dev] get pvc,secret,configmap -o name --no-headers | grep -i -F -e '-[username]' | xargs -I {} oc -n [-dev] delete '{}'

```
Next page - [Pod Lifecycle](./15_pod_lifecycle.md)
