## this script is intended for workshop facilitators doing cleanup
NAMESPACES=(d8f105)
SUFFIXES=(-dev -tools)
OBJECTS=(builds buildconfigs imagestreams deployments deploymentconfigs services replicationcontrollers statefulsets secret configmap pvc el route svc netpol pipelines pipelineruns tasks pdb triggerBindings triggerTemplates vpa hpa)
FILTER_STRINGS=("username")  # Add the list of usernames with "quotemarks" around each, spaces to seperate

for namespace in "${NAMESPACES[@]}"; do
  for suffix in "${SUFFIXES[@]}"; do
    for object in "${OBJECTS[@]}"; do
      for filter_string in "${FILTER_STRINGS[@]}"; do
        oc -n "${namespace}${suffix}" get "$object" --no-headers -o custom-columns=":metadata.name" | while read -r name; do
          if [[ $name == *"$filter_string"* ]]; then
            oc -n "${namespace}${suffix}" delete "$object/$name" 
          fi
        done
      done
    done
  done
done